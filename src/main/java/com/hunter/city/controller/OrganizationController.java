package com.hunter.city.controller;

import com.auth0.jwt.JWT;
import com.hunter.city.model.Organization;
import com.hunter.city.model.User;
import com.hunter.city.repository.OrganizationRepository;
import com.hunter.city.repository.UserRepository;
import com.hunter.city.security.JwtProperties;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import java.sql.Timestamp;
import java.util.Arrays;
import java.util.List;

import static com.auth0.jwt.algorithms.Algorithm.HMAC512;

@Slf4j
@Controller
public class OrganizationController {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private OrganizationRepository organizationRepository;

    @PostMapping("/getPlace")
    @ResponseBody
    public List<Organization> getPlace(HttpServletRequest request) {
        try {
            String username = null;
            String token = Arrays.stream(request.getCookies())
                    .filter(cookie -> cookie.getName().equals(JwtProperties.HEADER_STRING)).findFirst().map(Cookie::getValue)
                    .orElse(null).replace(JwtProperties.TOKEN_PREFIX,"");
            if (token != null) {
                username = JWT.require(HMAC512(JwtProperties.SECRET.getBytes()))
                        .build()
                        .verify(token)
                        .getSubject();
            }
            int user_id = userRepository.findByUsername(username).getId();
            List<Organization> list = organizationRepository.selectOrganization(user_id);
            return list;
        }catch (Exception e){
            e.printStackTrace();
            return null;
        }
    }

    @PostMapping("/setPeople")
    @ResponseBody
    public int setPeople(HttpServletRequest request) {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            int now_capacity = Integer.parseInt(request.getParameter("now_capacity"));
            int female = Integer.parseInt(request.getParameter("female"));
            int male = Integer.parseInt(request.getParameter("male"));
            Timestamp timestamp = new Timestamp(System.currentTimeMillis());
            organizationRepository.updatePeople(id, now_capacity, female, male, timestamp);
            return 1;
        }catch (Exception e){
            e.printStackTrace();
            return 0;
        }
    }

    @PostMapping("/delData")
    @ResponseBody
    public int delData(HttpServletRequest request) {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            organizationRepository.delFlag(id);
            return 1;
        }catch (Exception e){
            e.printStackTrace();
            return 0;
        }
    }

    @RequestMapping(value = "/orga_list")
    public String orgaList(HttpServletRequest request, Model model) {
        try {
            String username = null;
            String token = Arrays.stream(request.getCookies())
                    .filter(cookie -> cookie.getName().equals(JwtProperties.HEADER_STRING)).findFirst().map(Cookie::getValue)
                    .orElse(null).replace(JwtProperties.TOKEN_PREFIX,"");
            if (token != null) {
                username = JWT.require(HMAC512(JwtProperties.SECRET.getBytes()))
                        .build()
                        .verify(token)
                        .getSubject();
            }
//            List<Organization> list = userRepository.findByUsername(username).getOrganization();
            int user_id = userRepository.findByUsername(username).getId();
            List<Organization> list = organizationRepository.selectOrganization(user_id);
            model.addAttribute("list", list);
            return "/customer/list";
        }catch (Exception e){
            e.printStackTrace();
            return "/login";
        }
    }

    @PostMapping("/orgaRegistProc")
    @ResponseBody
    public int orgaRegistProc(HttpServletRequest request) {
        try {
            String username = null;
            String token = Arrays.stream(request.getCookies())
                    .filter(cookie -> cookie.getName().equals(JwtProperties.HEADER_STRING)).findFirst().map(Cookie::getValue)
                    .orElse(null).replace(JwtProperties.TOKEN_PREFIX,"");
            if (token != null) {
                username = JWT.require(HMAC512(JwtProperties.SECRET.getBytes()))
                        .build()
                        .verify(token)
                        .getSubject();
            }
            Organization orga = new Organization();
            orga.setLocationX(request.getParameter("location_x"));
            orga.setLocationY(request.getParameter("location_y"));
            orga.setOrganizationName(request.getParameter("organization_name"));
            orga.setOwnerName(request.getParameter("owner_name"));
            orga.setRoadAddress(request.getParameter("road_address"));
            orga.setAddress(request.getParameter("address"));
            orga.setTotalCapacity(Integer.parseInt(request.getParameter("total_capacity")));
            orga.setDivision(Integer.parseInt(request.getParameter("division")));
            int division = Integer.parseInt(request.getParameter("division"));
            orga.setTelNumber(request.getParameter("tel_number"));

            if(division == 1){
                orga.setCompanyCode(Integer.parseInt(request.getParameter("company_code")));
            }else if(division == 2){
                orga.setCompanyCode(Integer.parseInt(request.getParameter("company_code")));
                orga.setCorporateCode(Integer.parseInt(request.getParameter("corporate_code")));
            }else if(division == 3){
                orga.setCorporateCode(Integer.parseInt(request.getParameter("corporate_code")));
            }
            User user = userRepository.findByUsername(username);
            orga.setUser(user);
            organizationRepository.save(orga);
            return 1;
        }catch (Exception e){
            e.printStackTrace();
            return 0;
        }
    }

    @PostMapping("/orgaModifyProc")
    @ResponseBody
    public int orgaModifyProc(HttpServletRequest request) {
        try {
            String username = null;
            String token = Arrays.stream(request.getCookies())
                    .filter(cookie -> cookie.getName().equals(JwtProperties.HEADER_STRING)).findFirst().map(Cookie::getValue)
                    .orElse(null).replace(JwtProperties.TOKEN_PREFIX,"");
            if (token != null) {
                username = JWT.require(HMAC512(JwtProperties.SECRET.getBytes()))
                        .build()
                        .verify(token)
                        .getSubject();
            }
            Organization orga = new Organization();
            orga.setId(Integer.parseInt(request.getParameter("id")));
            orga.setLocationX(request.getParameter("location_x"));
            orga.setLocationY(request.getParameter("location_y"));
            orga.setOrganizationName(request.getParameter("organization_name"));
            orga.setOwnerName(request.getParameter("owner_name"));
            orga.setRoadAddress(request.getParameter("road_address"));
            orga.setAddress(request.getParameter("address"));
            orga.setTotalCapacity(Integer.parseInt(request.getParameter("total_capacity")));
            orga.setDivision(Integer.parseInt(request.getParameter("division")));
            int division = Integer.parseInt(request.getParameter("division"));
            orga.setTelNumber(request.getParameter("tel_number"));

            if(division == 1){
                orga.setCompanyCode(Integer.parseInt(request.getParameter("company_code")));
            }else if(division == 2){
                orga.setCompanyCode(Integer.parseInt(request.getParameter("company_code")));
                orga.setCorporateCode(Integer.parseInt(request.getParameter("corporate_code")));
            }else if(division == 3){
                orga.setCorporateCode(Integer.parseInt(request.getParameter("corporate_code")));
            }
            User user = userRepository.findByUsername(username);
            orga.setUser(user);
            organizationRepository.save(orga);
            return 1;
        }catch (Exception e){
            e.printStackTrace();
            return 0;
        }
    }
}
