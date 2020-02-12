package com.hunter.city.controller;

import com.hunter.city.model.User;
import com.hunter.city.repository.UserRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;


@Slf4j
@Controller
public class UserController {

    @Autowired
    private PasswordEncoder encoder;

    @Autowired
    private UserRepository userRepository;

    @RequestMapping(value = "/user")
    public String userMain() {
        return "/user/main";
    }

    @RequestMapping(value = "/customer")
    public String customerMain() {
        return "/customer/main";
    }

    @RequestMapping(value = "/signup")
    public String signup() {
        return "/signup";
    }

    @RequestMapping(value = "/signupGroup")
    public String group() {
        return "signupGroup";
    }

//    @RequestMapping(value = "/login")
//    public String login() { return "login"; }

    @GetMapping("login")
    public void loginPage() {
    }

    @PostMapping("checkEmail")
    @ResponseBody
    public int checkEmail(String email) {
        if(userRepository.countByEmail(email) > 0){
            return 0;
        };
        return 1;
    }

    @PostMapping("checkUsername")
    @ResponseBody
    public int checkUser(String username) {
        if(userRepository.countByUsername(username) > 0){
            return 0;
        }
        return 1;
    }

    @PostMapping("signupProc")
    public String signupProc(User user) {
        String rawPassword = user.getPassword();
        String encPassword = encoder.encode(rawPassword);
        log.info(rawPassword);
        log.info(encPassword);
        user.setPassword(encPassword);
        user.setRoles("USER");

        userRepository.save(user);
        return "redirect:/login";
    }

    @PostMapping("signupGroupProc")
    public String signupGroupProc(User user) {
        String rawPassword = user.getPassword();
        String encPassword = encoder.encode(rawPassword);
        user.setPassword(encPassword);
        user.setRoles("CUSTOMER");

        userRepository.save(user);
        return "redirect:/login";
    }
}
