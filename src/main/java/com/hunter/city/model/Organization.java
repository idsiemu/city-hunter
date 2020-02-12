//package com.hunter.city.model;
//
//import com.fasterxml.jackson.annotation.JsonBackReference;
//import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
//import lombok.Data;
//import lombok.NoArgsConstructor;
//import org.hibernate.annotations.LazyToOne;
//import org.hibernate.annotations.LazyToOneOption;
//
//import javax.persistence.*;
//
//@Data //lombok
//@Entity //JPA -> ORM
//@NoArgsConstructor
//public class Organization {
//    @Id
//    @GeneratedValue(strategy = GenerationType.IDENTITY)
//    private int id; // 시퀀스
//
//    @Column(name = "representative_name", length = 50, nullable = false)
//    private String representativeName; // 대표자이름
//
//    @Column(nullable = false) //columnDefinition = "1. 개인사업자 2.영리법인 3.비영리법인"
//    private int division; // 단체 종류
//
//    @Column(name = "company_name", length = 50)
//    private String companyName;
//
//    @Column(name = "corporation_name",length = 50)
//    private String corporationName;
//}
