package com.deb.demo.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/")
public class HelloController {

	@GetMapping("home")
	@PreAuthorize("hasRole('ROLE_EMPLOYEE')")
	public ResponseEntity<String> hello() {
		return ResponseEntity.status(HttpStatus.OK).body("Hello, World!");
	}

}
