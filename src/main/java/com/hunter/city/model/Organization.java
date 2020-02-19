package com.hunter.city.model;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import javax.persistence.*;
import java.sql.Timestamp;

@Data //lombok
@Entity //JPA -> ORM
@NoArgsConstructor
@org.hibernate.annotations.DynamicUpdate
public class Organization {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id; // 시퀀스

    @Column(name = "owner_name", length = 50, nullable = false)
    private String ownerName; // 대표자이름

    @Column(nullable = false) //columnDefinition = "1. 개인사업자 2.영리법인 3.비영리법인"
    private int division; // 단체 종류

    @Column(name = "organization_name", length = 50)
    private String organizationName;

    @Column(name = "address", length = 124)
    private String address;

    @Column(name = "road_address", length = 124)
    private String roadAddress;

    @Column(name = "tel_number", length = 50)
    private String telNumber;

    @Column(name = "company_code")
    private int companyCode;

    @Column(name = "corporate_code")
    private int corporateCode;

    @Column(name = "location_x", length = 50)
    private String locationX; // X축

    @Column(name = "location_y", length = 50)
    private String locationY; // Y축

    @Column(name = "total_capacity")
    private int totalCapacity; // 수용인원

    @Column(name = "now_capacity")
    private int nowCapacity; // 현재인원

    private int female; // 여자인원

    private int male; // 남자인원

    private int anonymous; // 구분불가인원

    @Column(name = "del_flag")
    private int delFlag = 0;

    @Column(name = "start_time")
    private String startTime;

    @Column(name = "finish_time")
    private String finishTime;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    @JsonBackReference
    @JsonIgnoreProperties({"password", "store"})
    private User user;

    @CreationTimestamp // 자동으로 현재 시간이 세팅
    @Column(name = "create_date")
    private Timestamp createDate;

    @CreationTimestamp // 자동으로 현재 시간이 세팅
    @Column(name = "update_date")
    private Timestamp updateDate;
}
