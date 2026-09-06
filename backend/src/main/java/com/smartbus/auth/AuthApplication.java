package com.smartbus.auth;
import org.springframework.boot.SpringApplication; import org.springframework.boot.autoconfigure.SpringBootApplication; import org.springframework.boot.autoconfigure.domain.EntityScan; import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
@SpringBootApplication(scanBasePackages = "com.smartbus") @EntityScan("com.smartbus") @EnableJpaRepositories("com.smartbus") public class AuthApplication { public static void main(String[] args) { SpringApplication.run(AuthApplication.class,args); } }
