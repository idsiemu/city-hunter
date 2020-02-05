package com.hunter.city.controller;

import com.hunter.city.model.User;
import com.hunter.city.repository.UserRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.ResponseBody;


@Slf4j
@Controller
public class UserController {

    @Autowired
    private BCryptPasswordEncoder encoder;

    @Autowired
    private UserRepository userRepository;

    @GetMapping("/")
    public String indexPage() {
        return "/index";
    }

    @GetMapping("signup")
    public void signupPage() {
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
        user.setPassword(encPassword);

        userRepository.save(user);
        return "redirect:/login";
    }

    @GetMapping("login")
    public void loginPage() {
    }



    @PostMapping("loginProc")
    public String loginProc(User user) {

        return "redirect:/index";
    }
}
