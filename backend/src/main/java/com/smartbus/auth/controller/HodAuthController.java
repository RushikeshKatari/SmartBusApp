package com.smartbus.auth.controller;
import com.smartbus.auth.service.UserAuthService; import com.smartbus.manager.dto.ManagerLoginRequest; import java.util.Map; import org.springframework.web.bind.annotation.*;
@RestController @RequestMapping("/api/hod") public class HodAuthController { private final UserAuthService auth; public HodAuthController(UserAuthService auth){this.auth=auth;} @PostMapping("/login") public Map<String,String> login(@RequestBody ManagerLoginRequest request){return auth.login(request.username(),request.password(),"HOD");} }
