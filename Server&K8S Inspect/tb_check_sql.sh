#!/bin/bash

## Volume env
export TB_VOLUME=/db

## JAVA env
export JAVA_HOME=/usr/local/jdk
export CATALINA_OPTS=Djava.awt.headless=true 
export PATH=$PATH:$JAVA_HOME/bin
export CLASSPATH=$CLASSPATH:$JAVA_HOME/jre/lib/ext:$JAVA_HOME/lib/tools.jar
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$JAVA_HOME/jre/lib/amd64/server

## tibero env
export TB_HOME=$TB_VOLUME/tibero6 
export CLI_HOME=$TB_VOLUME/client
export TB_SID=tibero
export PATH=$PATH:$TB_HOME/bin:$TB_HOME/client/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$TB_HOME/lib:$TB_HOME/client/lib:$CLI_HOME/oracle_lib


TB_NM1="v\$sga"
TB_NM2="v\$parameters"
TB_NM3="v\$pgastat"
TB_NM4="v\$access"
TB_NM5="v\$lock"

echo "## 5-2. TB Config"
echo ""
echo "======================"
echo " Parameter Infomation "
echo "======================"
OUT1=`tbsql -s sys/tibero << EOF
set feedback off
set linesize 80
set pagesize 80

col "Parameter Name" format a40
col "Value" format a25

SELECT name "Parameter Name", value "Value" FROM sys._vt_parameter
WHERE  dflt_value <> value
       OR name in ('OPTIMIZER_MODE', 'EX_MEMORY_AUTO_MANAGEMENT', 
                   'EX_MEMORY_HARD_LIMIT','_WTHR_PER_PROC', 'UNDO_RETENTION')
ORDER BY 1;
EOF`

echo "${OUT1}"
echo ""
echo "--------------------------------------------------------------------"
echo "## 5-3. TB Memory Check"
echo ""
echo "====================="
echo " TSM(SGA) Infomation "
echo "====================="
OUT2=`tbsql -s sys/tibero << EOF
set linesize 130
set feedback off

col "Size" format a20

SELECT name
  , round(total/1024/1024) || '(MB)' AS "Size"
FROM ${TB_NM1}
WHERE name in ('SHARED MEMORY', 'SHARED POOL MEMORY', 'Database Buffers', 'Redo Buffers')
UNION ALL
SELECT name
  , round(value/1024) || '(KB)' AS "Size"
FROM ${TB_NM2}
WHERE name = 'DB_BLOCK_SIZE';
EOF`
echo "${OUT2}"
echo ""
echo "==============================="
echo " Tibero Used Memory Infomation "
echo "==============================="
OUT3=`tbsql -s sys/tibero << EOF
set linesize 130
set feedback off

select name, round(value/1024/1024, 2) "Size(MB)"
from ${TB_NM2}
where name = 'MEMORY_TARGET'
union all
select 'SGA(Used)' name, round(sum(used)/1024/1024, 2) "Size(MB)"
from ${TB_NM1}
where name in ('FIXED MEMORY', 'SHARED POOL MEMORY')
union all
select 'PGA(Allocated)' name, round(sum(value)/1024/1024, 2) "Size(MB)"
from ${TB_NM3}
where name in ('FIXED pga memory', 'ALLOCATED pga memory')
union all
select 'PGA(Used)' name, round(value/1024/1024, 2) "Size(MB)"
from ${TB_NM3}
where name = 'USED pga memory (from ALLOCATED)';
EOF`
echo "${OUT3}"
echo ""
echo "--------------------------------------------------------------------"
echo "## 5-4. TB Session Check"
echo ""
echo "======================="
echo " Blocking/Waiting Lock "
echo "======================="
OUT4=`tbsql -s sys/tibero << EOF
set feedback off
set linesize 150
set pagesize 20

col "Blocking User" format a15
col "Waiting User" format a15
col "Blocking Sid" format 999999999999
col "Waiting Sid" format 99999999999
col "Lock Type" format a12
col "Holding mode" format a15
col "Request mode" format a15

SELECT bs.user_name "Blocking User"
      ,ws.user_name "Waiting User"
      ,bs.sess_id "Blocking Sid"
      ,ws.sess_id "Waiting Sid"
      ,wk.type "Lock Type"
      ,DECODE(hk.lmode, 0, '[0]', 1, '[1]Row-S(RS)', 2, '[2]Row-X(RX)', 3, '[3]Shared(S)', 4, '[4]S/Row-S(SRX)', 5, '[5]Exclusive(X)', 6, '[6]PIN', TO_CHAR (hk.lmode) )  "Holding mode"
      ,DECODE(wk.lmode, 0, '[0]', 1, '[1]Row-S(RS)', 2, '[2]Row-X(RX)', 3, '[3]Shared(S)', 4, '[4]S/Row-S(SRX)', 5, '[5]Exclusive(X)', 6, '[6]PIN', TO_CHAR (wk.lmode) )  "Request mode"
      ,NVL(bs.sql_id, bs.prev_sql_id) || '/' || NVL2(bs.sql_id, bs.sql_child_number, bs.prev_child_number) "SQL_ID"
   FROM vt_wlock hk, 
        vt_session bs, 
        vt_wlock wk, 
        vt_session ws
  WHERE wk.status in( 'WAITER','CONVERTER')
    and hk.status = 'OWNER'
    and hk.lmode > decode(wk.status,'WAITER',1,0)
    and wk.type = hk.type
    and wk.id1 = hk.id1
    and wk.id2 = hk.id2
    and wk.sess_id = ws.sess_id
    and hk.sess_id = bs.sess_id
    and bs.sess_id != ws.sess_id
  ORDER BY 1,3;
EOF`
echo "${OUT4}"
echo ""
echo "======================"
echo " DML Lock Information "
echo "======================"
OUT5=`tbsql -s sys/tibero << EOF
set feedback off
set linesize 200
set pagesize 100

col "User" format a15
col "Sid" format 9999
col "Object" format a35
col "Status" format a8
col "Lock_time" format a15
col "Lock mode" format a15

SELECT s.sess_id  "Sid"
      ,s.status "Status"
      ,s.user_name "User"
      ,o.owner|| '.' ||o.object_name "Object"
      ,FLOOR((sysdate - vt.start_time)*24) || ':'||
        LPAD(FLOOR(MOD((sysdate - vt.start_time)*1440, 60)),2,0) ||':'||
        LPAD(FLOOR(MOD((sysdate - vt.start_time)*86400,60)),2,0) AS "Lock_time"
      ,DECODE(lmode, 0, '[0]', 1, '[1]Row-S(RS)', 2, '[2]Row-X(RX)', 3, '[3]Shared(S)', 4, '[4]S/Row-S(SRX)', 5, '[5]Exclusive(X)', 6, '[6]PIN', TO_CHAR (lmode) )  "Lock mode"
      --,NVL(s.sql_id, s.prev_sql_id) "SQL_ID"
      ,NVL(s.sql_id, s.prev_sql_id) || '/' || NVL2(s.sql_id, s.sql_child_number, s.prev_child_number) "SQL_ID"
 FROM vt_wlock l, 
      vt_session s,  
      dba_objects o ,
      vt_transaction vt
WHERE l.type='WLOCK_DML'
  AND l.sess_id = s.vtr_tid
  AND l.id1 = o.object_id (+)
  AND l.sess_id = vt.sess_id order by "Lock_time" DESC;
EOF`
echo "${OUT5}"
echo ""
echo "============================================"
echo " Object Lock Information(Library cache Lock)       "
echo "============================================"
OUT6=`tbsql -s sys/tibero << EOF
set feedback off
set linesize 150
set pagesize 50

col "Owner" format a15
col "Sid" format 9999
col "Object" format a35
col "Lock_type" format a15
col "Type" format a15

select SID "Sid",
       OWNER "Owner",
       OBJECT "Object",
       TYPE "Type",
       'WLOCK_DD_OBJ' Lock_type
from ${TB_NM4}
where sid in (
       select sess_id from ${TB_NM5}
       where type='WLOCK_DD_OBJ'
       )
and owner != 'SYS';
EOF`
echo "${OUT6}"
echo ""
echo "--------------------------------------------------------------------"
echo "## 5-5. TB Tablespace Check"
echo ""
echo "======================="
echo " Tablespace Infomation "
echo "======================="
OUT7=`tbsql -s sys/tibero << EOF
set feedback off
set linesize 130
set pagesize 20

col "Tablespace Name" format a20
col "Bytes(MB)"       format 999,999,999
col "Used(MB)"        format 999,999,999
col "Percent(%)"      format 9999999.99
col "Free(MB)"        format 999,999,999
col "Free(%)"         format 9999.99
col "MaxBytes(MB)"    format 999,999,999

SELECT ddf.tablespace_name "Tablespace Name",
       ddf.bytes/1024/1024 "Bytes(MB)",
       (ddf.bytes - dfs.bytes)/1024/1024 "Used(MB)",
       round(((ddf.bytes - dfs.bytes) / ddf.bytes) * 100, 2) "Percent(%)",
       dfs.bytes/1024/1024 "Free(MB)",
       round((1 - ((ddf.bytes - dfs.bytes) / ddf.bytes)) * 100, 2) "Free(%)",
       ROUND(ddf.MAXBYTES / 1024/1024,2) "MaxBytes(MB)"      
FROM
 (SELECT tablespace_name, sum(bytes) bytes, sum(maxbytes) maxbytes
   FROM   dba_data_files
   GROUP BY tablespace_name) ddf,
 (SELECT tablespace_name, sum(bytes) bytes
   FROM   dba_free_space
   GROUP BY tablespace_name) dfs
WHERE ddf.tablespace_name = dfs.tablespace_name
ORDER BY ((ddf.bytes-dfs.bytes)/ddf.bytes) DESC;

EOF`

echo "${OUT7}"
echo ""
echo "============================"
echo " Temp Tablespace Infomation "
echo "============================"
OUT8=`tbsql -s sys/tibero << EOF
set linesize 130
set feedback off

col "Tablespace Name" format a20
col "Size(MB)" format 999,9999,999.99
col "MaxSize(MB)" format 999,9999,999.99

SELECT tablespace_name "Tablespace Name",
       SUM(bytes)/1024/1024 "Size(MB)",
       SUM(maxbytes)/1024/1024 "MaxSize(MB)"
FROM dba_temp_files
GROUP BY tablespace_name
ORDER BY 1;
EOF`
echo "${OUT8}"
echo ""
