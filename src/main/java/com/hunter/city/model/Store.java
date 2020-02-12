//package com.hunter.city.model;
//
//import com.fasterxml.jackson.annotation.JsonBackReference;
//import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
//import lombok.Data;
//import lombok.NoArgsConstructor;
//import org.hibernate.annotations.CreationTimestamp;
//
//import javax.persistence.*;
//import java.sql.Timestamp;
//
//@Data //lombok
//@Entity //JPA -> ORM
//@NoArgsConstructor
//class Store {
//    @Id
//    @GeneratedValue(strategy = GenerationType.IDENTITY)
//    private int id; // 시퀀스
//
//    @Column(name = "store_name", length = 50, nullable = false)
//    private String storeName; // 가게이름
//
//    @Column(name = "location_x", length = 50, nullable = false)
//    private String locationX; // X축
//
//    @Column(name = "location_y", length = 50, nullable = false)
//    private String locationY; // Y축
//
//    @Column(name = "total_capacity", nullable = false)
//    private int totalCapacity; // 수용인원
//
//    @Column(name = "now_capacity")
//    private int nowCapacity; // 현재인원
//
//    private int female; // 여자인원
//
//    private int male; // 남자인원
//
//    private int anonymous; // 구분불가인원
//
//    @ManyToOne(fetch = FetchType.LAZY)
//    @JoinColumn(name = "user_id")
//    @JsonBackReference
//    @JsonIgnoreProperties({"password", "store"})
//    private User user;
//
//    @CreationTimestamp // 자동으로 현재 시간이 세팅
//    @Column(name = "create_date")
//    private Timestamp createDate;
//
//    @CreationTimestamp // 자동으로 현재 시간이 세팅
//    @Column(name = "update_date")
//    private Timestamp updateDate;
//}
