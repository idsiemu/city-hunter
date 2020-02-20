package com.hunter.city.repository;

import com.hunter.city.model.Organization;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import javax.transaction.Transactional;
import java.sql.Timestamp;
import java.util.List;

public interface OrganizationRepository extends JpaRepository<Organization, Integer> {
    @Transactional
    @Modifying
    @Query
    (
            value = "UPDATE organization SET" +
                    "  start_time = :start_time" +
                    ", finish_time = :finish_time" +
                    ", work_day = :work_day" +
                    ", now_capacity = :now_capacity" +
                    ", female = :female" +
                    ", male = :male" +
                    ", update_date = :update_date " +
                    "WHERE id = :id", nativeQuery = true
    )
    void updatePeople(@Param("id") int id, @Param("start_time") String start_time, @Param("finish_time") String finish_time, @Param("work_day") String work_day, @Param("now_capacity") int now_capacity, @Param("female") int female, @Param("male") int male, @Param("update_date") Timestamp update_date);

    @Query(value = "SELECT * FROM organization WHERE user_id = ?1 AND del_flag = 0", nativeQuery = true)
    List<Organization> selectOrganization(int userId);

    @Transactional
    @Modifying
    @Query(value = "UPDATE organization SET del_flag = 1 WHERE id = ?1", nativeQuery = true)
    void delFlag(int id);

    int countByCompanyCode(int company_code);

    int countByCorporateCode(int corporate_code);
}
