package com.hunter.city.controller;

import com.hunter.city.model.Organization;
import com.hunter.city.model.User;
import com.hunter.city.repository.UserRepository;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.weaver.ast.Or;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.persistence.Column;
import javax.servlet.http.HttpServletRequest;
import java.util.ArrayList;
import java.util.List;


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

    @RequestMapping(value = "/login")
    public String login() { return "login"; }

    @PostMapping("/checkemail")
    @ResponseBody
    public int checkEmail(String email) {
        if(userRepository.countByEmail(email) > 0){
            return 0;
        };
        return 1;
    }

    @PostMapping("/checkusername")
    @ResponseBody
    public int usernameCheck(String username) {
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
        user.setRoles("USER");

        userRepository.save(user);
        return "redirect:/login";
    }

    @PostMapping("signupGroupProc")
    @ResponseBody
    public int signupGroupProc(HttpServletRequest request) {
        try {
            User user = new User();
            Organization organization = new Organization();
            List<Organization> list = new ArrayList<>();

            user.setUsername(request.getParameter("username"));
            user.setPassword(encoder.encode(request.getParameter("password")));
            user.setEmail(request.getParameter("email"));
            user.setRoles("CUSTOMER");
            organization.setOwnerName(request.getParameter("owner_name"));
            int division = Integer.parseInt(request.getParameter("division"));
            organization.setDivision(division);
            if(division == 1){
                organization.setCompanyCode(Integer.parseInt(request.getParameter("company_code")));
            }else if(division == 2){
                organization.setCompanyCode(Integer.parseInt(request.getParameter("company_code")));
                organization.setCorporateCode(Integer.parseInt(request.getParameter("corporate_code")));
            }else if(division == 3){
                organization.setCorporateCode(Integer.parseInt(request.getParameter("corporate_code")));
            }
            organization.setUser(user);

            list.add(organization);
            user.setOrganization(list);
            userRepository.save(user);
            return 1;
        }catch (Exception e){
            e.printStackTrace();
            return 0;
        }
    }
}
