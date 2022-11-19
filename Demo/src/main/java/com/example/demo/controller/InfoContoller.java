package com.example.demo.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class InfoContoller {
	
	@GetMapping("/info")
	public String projectInfo() {
		return "Project name is kakayopay";
	}
}
