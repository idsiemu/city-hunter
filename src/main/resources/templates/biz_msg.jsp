<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
%>
<jsp:include page="loginCheck.do" flush="true"></jsp:include>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <link rel="stylesheet" href="../css/style.css" type="text/css">
    <link rel="stylesheet" href="../css/myDialog/myDialog.css" type="text/css">
    <link rel="stylesheet" href="../calendar/css/aqua/theme.css" type="text/css">
    <!-- <link rel="stylesheet" href="https://uicdn.toast.com/tui-image-editor/latest/tui-image-editor.css"> -->
    <link rel="stylesheet" type="text/css" href="https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css">
    <title>BIZ_MSG 발송</title>
    <link rel="shortcut icon" href="../img/srmoa.ico" />

    <!-- DWR Core -->
    <script type='text/javascript' src='../../../dwr/engine.js'></script>
    <script type='text/javascript' src='../../../dwr/interface/employeeDwr.js'></script>
    <script type='text/javascript' src='../../../dwr/interface/relationDwr.js'></script>
    <script type='text/javascript' src='../../../dwr/interface/insureCommonDwr.js'></script>
    <script type='text/javascript' src='../../../dwr/interface/commonUploadDwr.js'></script>
    <script type='text/javascript' src='../../../dwr/interface/bizMsgSrmoaDwr.js'></script>
    <script type='text/javascript' src='../../../dwr/interface/counselChargeDwr.js'></script>

    <!-- jQuery Core -->
    <script type="text/javascript" src='../js/jquery.min.js'></script>
    <script type="text/javascript" src='../js/jquery.form.js'></script>
    <script type="text/javascript" src='../js/myDialog.js'></script>

    <!-- util -->
    <script type="text/javascript" src='../js/code.js'></script>
    <script type="text/javascript" src='../js/selectbox.js'></script>
    <script type="text/javascript" src='../js/main.js'></script>
    <script type='text/javascript' src='../calendar/jquery.dynDateTime.js'></script>
    <script type='text/javascript' src='../calendar/calendar-kr.js'></script>
    <script type="text/javascript" src='../js/xlsx.full.min.js'></script>

    <!-- 이미지 편집 -->
    <!-- <script src="https://uicdn.toast.com/tui-image-editor/latest/tui-image-editor.js"></script> -->
    <!-- <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/fabric.js/3.3.2/fabric.js"></script> -->
    <!-- <script type="text/javascript" src="https://uicdn.toast.com/tui.code-snippet/v1.5.0/tui-code-snippet.min.js"></script> -->
    <!-- <script type="text/javascript" src="https://uicdn.toast.com/tui-color-picker/v2.2.3/tui-color-picker.js"></script> -->

        <%
String SESSION_ID = (String)session.getAttribute("ID");
int DIVISION      = (Integer)session.getAttribute("DIVISION");
%>
    <script>

        // var imageEditor = new tui.ImageEditor('#my-image-editor canvas', {
        //     cssMaxWidth: 1000,
        //     cssMaxHeight: 800
        // });
        // imageEditor.loadImageFromURL('asdf.jpg', 'My sample image');

        var setDivision   = <%= DIVISION %>;
        var setId         ='<%= SESSION_ID %>';
        var paramDivision = <%= request.getParameter("division") == null ? 1 : request.getParameter("division") %>;
        var chargeSeq = <%= request.getParameter("chargeSeq") == null ? 0 : request.getParameter("chargeSeq") %>;
        /*******************************************************************************************
         * 액션
         *******************************************************************************************/
//  window.addEventListener("beforeunload", function(event) {
//   event.returnValue = "123123";
//  });
        jQuery(function()
        {
            // 보내기
            $('[name=btn_insert]').click(function()
            {
                bizMsgInsert();
            });

            //닫기
            $('[name=btn_cancel]').click(function()
            {
                self.close();
            });

            //초기화
            bizMsgInit();

            //직접등록 이름 감지
//      $('input[id^=register]').keyup(function(e){
//       registerByTyping($(this).attr('id').substr($(this).attr('id').length - 1), e);
//      });
            $(document).bind('keyup','input[id^=register]',function(e){
                //register 라는 단어가 들어간것만 넘어가게 나중에 설정해줘야함. 지금 input 박스에 모두 리스너가 달려버림
                var id = $(this).context.activeElement.id;
                if(!(id.indexOf('message') == 0 || id.indexOf('dest_name') == 0 || id == '' || id.indexOf('cal_date') == 0)&&e.which != 9){
                    registerByTyping(id.substr(id.length - 1), e.which);
                }
            });

            //직접등록 전화번호 감지
//      $('input[id^=register_phone]').keyup(function(e){
//       registerByTyping($(this).attr('id').substr($(this).attr('id').length - 1), e);
//      });

            //엑셀등록
            if(document.getElementById('file2').addEventListener) {
                document.getElementById('file2').addEventListener('change', handleFile, false);
            }

            //파일첨부
            $('[id^=bizMsg_fileElement]').change(function(){
                fileUpload(this);
            });

            //예약 팝업 띄우기
            $('[id^=reserve_chk]').click(function(){
                reservationDateInit(paramDivision);
                document.getElementById('reserve_popup'+paramDivision).style.display = 'block';
            });

            // 사원 검색 - 검색항목 인터페이스(셀렉트)
            $('#bizMsgSmsArea select[name=codeSeq2], #bizMsgSmsArea select[name=codeSeq6], #bizMsgSmsArea select[name=codeSeq101], #bizMsgSmsArea select[name=codeSeq102], #bizMsgSmsArea select[name=isRetirement]').change(function()
            {
                document.getElementsByName('employee_name')[0].value = '';
                bizMsgEmployeeSearch();
            });

            // 사원 검색 - 검색항목 인터페이스(텍스트)
            $('input[name=employee_name]').keypress(function(e){
                var keyCodeNumber;
                if(window.event) {
                    keyCodeNumber = event.keyCode;
                } else if (e) {
                    keyCodeNumber = e.which;
                }
                if(keyCodeNumber == 13)
                {
                    bizMsgEmployeeSearch();
                }
            });

            // 유망고객 검색 - 검색항목 인터페이스(텍스트)
            $('input[name=relation_name], input[name=relation_hp]').keypress(function(e){
                var keyCodeNumber;
                if(window.event){
                    keyCodeNumber = event.keyCode;
                } else if (e) {
                    keyCodeNumber = e.which;
                }
                if(keyCodeNumber == 13){
                    bizMsgRelationSearch();
                }
            });
            // 계약고객 검색 - 검색항목 인터페이스(텍스트)
            $('input[name=member_name], input[name=member_hp]').keypress(function(e){
                var keyCodeNumber;
                if(window.event) {
                    keyCodeNumber = event.keyCode;
                } else if (e) {
                    keyCodeNumber = e.which;
                }
                if(keyCodeNumber == 13){
                    bizMsgMemberSearch();
                }
            });

            // 사원 검색 - 검색항목 인터페이스(텍스트)
            $('#dest_name2 ,#dest_name3').keypress(function(e){
                var keyCodeNumber;
                if(window.event) {
                    keyCodeNumber = event.keyCode;
                } else if (e) {
                    keyCodeNumber = e.which;
                }
                if(keyCodeNumber == 13)
                {
                    var tab = this.id.replace(/[^0-9]/g,"");
                    msgSearchList(tab, 4);
                }
            });

            $('.emoticon').click(function(){
                document.getElementsByClassName('emoticon_popup')[0].style.display = 'block';
            });

            $('[id^=emoticon_str]').click(function(){
                document.getElementById('message_body2').value = this.value;
                document.getElementsByClassName('emoticon_popup')[0].style.display = 'none';
                messageToByte(0);
            });

            $('#emoticon_close').click(function(){
                document.getElementsByClassName('emoticon_popup')[0].style.display = 'none';
            })

            $('#delete_total_file').click(function(){
                bizMsgDeleteTotalFile();
            })

            $('#result_search2 ,#result_search3').click(function(){
                var tab = this.id.replace(/[^0-9]/g,"");
                msgSearchList(tab, 4);
            });

            $('[id^=today], [id^=oneMonth], [id^=threeMonth]').click(function(){
                var tab = this.id.replace(/[^0-9]/g,"");
                var division;
                if(this.id.length < 9){
                    division = 1
                }else if(this.id.length == 9){
                    division = 2
                }else if(this.id.length > 9){
                    division = 3
                }
                msgSearchList(tab, division);
            });
        });
        /*******************************************************************************************
         * 초기화
         *******************************************************************************************/
        function bizMsgInit()
        {
            if(setDivision == 1 || paramDivision != 3){
                bizMsgTabAction(paramDivision);
            }else{
                bizMsgTabAction(2);
            }
        }
        /*******************************************************************************************
         * 탭 액션
         *******************************************************************************************/
        function bizMsgTabAction(division)
        {
            if(division == 1){
                alert('준비중입니다.');
                paramDivision = 2;
                division = 2;
            }
            for(var i = 1; i <= 4 ; i++)
            {
                if(setDivision == 1 || i != 3){
                    document.getElementById('bizMsg_menu_btn'+i).classList.remove('on');
                    document.getElementById('bizMsgArea'+i).style.display = 'none';
                }
            }
            document.getElementById('bizMsg_menu_btn'+division).classList.add('on');
            document.getElementById('bizMsgArea'+division).style.display = 'block';
            if(division == 1){
                //알림톡 완료시 코딩작성

            }else if(division == 2){
                document.getElementById('bizMsgDestArea'+division).innerHTML = '';
                document.getElementById('message_body'+division).value = "";
                paramDivision = division;
                registerByTypingInit(division);
                emoticonInit();
                document.getElementById('radio01').checked = true;
                messageToByte(0);
                destCount();
                bizMsgSenderInit();
                bizMsgEmployeeInit();
                bizMsgRelationSearch();
                bizMsgMemberSearch();
                bizMsgSmsTabAction(1);
            }else if(division == 3){
                document.getElementById('bizMsgDestArea'+division).innerHTML = '';
                paramDivision = division;
                registerByTypingInit(division);
                bizMsgSenderInit();
                destCount();
                bizMsgRelationSearch();
                bizMsgFaxAddressSearch();
                bizMsgFaxTabAction(2);
                if(chargeSeq != 0){
                    chargeSeqImageList();
                }
            }else if(division == 4){
                paramDivision = division;
                bizMsgResultTabAction(2);
            }
        }
        /*******************************************************************************************
         * 알림톡
         *******************************************************************************************/


        /*******************************************************************************************
         * 문자발송 - 검색 탭 액션
         *******************************************************************************************/
        function bizMsgSmsTabAction(tab){
            for(var i = 1; i <= 5 ; i++){
                document.getElementById('bizMsg_sms_search_tab'+i).classList.remove('on');
            }
            document.getElementById('bizMsg_sms_search_tab'+tab).classList.add('tab0'+tab, 'on');
        }
        /*******************************************************************************************
         * 팩스발송 - 검색 탭 액션
         *******************************************************************************************/
        function bizMsgFaxTabAction(tab){
            for(var i = 1; i <=3 ; i++){
                document.getElementById('bizMsg_fax_search_tab'+i).classList.remove('on');
            }
            document.getElementById('bizMsg_fax_search_tab'+tab).classList.add('tabo'+tab, 'on');
        }
        /*******************************************************************************************
         * 보내는 사람 생성
         *******************************************************************************************/
        function bizMsgSenderInit(){
            bizMsgSrmoaDwr.init(function(map) {
                var inner_number = '';
                var fax_number = '';
                var representative_number = '';

                if(map['employeeVo'].hp == '01038475293') inner_number = '0517144421';
                if(map['employeeVo'].hp == '01062046871') inner_number = '0517173002';
                if(map['employeeVo'].hp == '01096647676') inner_number = '0517173004';
                if(map['employeeVo'].hp == '01091563889') inner_number = '0517173001';
                if(map['employeeVo'].hp == '0118873204') inner_number = '0517144603';
                if(map['employeeVo'].hp == '01045727692') inner_number = '0517144548';
                if(map['employeeVo'].hp == '01087663053') inner_number = '0517144592';
                if(map['employeeVo'].hp == '01046261769') inner_number = '0517144430';
                if(map['employeeVo'].hp == '01057754171') inner_number = '0517144565';
                if(map['employeeVo'].hp == '01052548936') inner_number = '0517173047';
                if(map['employeeVo'].hp == '01062453252') inner_number = '0553339951';
                if(map['employeeVo'].hp == '01066757475') inner_number = '0517144418';
                if(map['employeeVo'].hp == '01091512402') inner_number = '0553339954';
                if(map['employeeVo'].hp == '01051756490') inner_number = '0517173047';
                if(map['employeeVo'].hp == '01031388303') inner_number = '0517173023';
                if(map['employeeVo'].hp == '01084342955') inner_number = '0517144521';
                if(map['employeeVo'].hp == '01074790318') inner_number = '0517144514';
                if(map['employeeVo'].hp == '01085032109') inner_number = '0517144429';

                if(map['employeeVo'].hp == '01025787882') inner_number = '0517144434';

                if(map['employeeVo'].hp == '01093525095') inner_number = '0517144483';
                if(map['employeeVo'].hp == '01075725292') inner_number = '0517173047';
                if(map['employeeVo'].hp == '01094672963') inner_number = '0517144547';
                if(map['employeeVo'].hp == '01023034029') inner_number = '0517144593';
                if(map['employeeVo'].hp == '01040367433') inner_number = '0517144590';
                if(map['employeeVo'].hp == '01039220232') inner_number = '0517144593';  // 2018.04.24.김대훈.조수연총무 추가
                if(map['employeeVo'].hp == '01065648697') inner_number = '0517144589';
                if(map['employeeVo'].hp == '01029089859') inner_number = '0517173042';  // 2019.02.21.왕윤진.채송화총무 추가
                if(map['employeeVo'].hp == '01045668846') inner_number = '0517144592';
                if(map['employeeVo'].hp == '01054584175') inner_number = '0517144547';
                if(map['employeeVo'].hp == '01039054914') inner_number = '0517144593';
                if(map['employeeVo'].hp == '01067883284') inner_number = '0553339954';
                if(map['employeeVo'].hp == '01055120176') inner_number = '0517144427';
                if(map['employeeVo'].hp == '01085590754') inner_number = '0517144428';
                if(map['employeeVo'].hp == '01028345492') inner_number = '0517144547';
                if(map['employeeVo'].hp == '01057175884') inner_number = '0517144430';
                if(map['employeeVo'].hp == '01039054914') inner_number = '0517144430';
                if(map['employeeVo'].hp == '01062199554') inner_number = '0517173003';
                if(map['employeeVo'].hp == '01074449904') inner_number = '0517144433';
                if(map['employeeVo'].hp == '01025679896') inner_number = '0517144593';
                if(map['employeeVo'].hp == '01052746035') inner_number = '0553813161';
                if(map['employeeVo'].hp == '01024353909') inner_number = '0517144612';
                if(map['employeeVo'].hp == '01097715244') inner_number = '0517144599';
                if(map['employeeVo'].hp == '01068222341') inner_number = '0552863160';
                if(map['employeeVo'].hp == '01045698790') inner_number = '0552863162';

                if(map['employeeVo'].hp == '01025459841') inner_number = '0517144414';
                if(map['employeeVo'].hp == '01038834174') inner_number = '0517144404';
                if(map['employeeVo'].hp == '01067128555') inner_number = '0517144587';

                if(map['employeeVo'].hp == '01045510978') inner_number = '01066203718';

                if(map['employeeVo'].hp == '01025459841') representative_number = '15221001';
                if(map['employeeVo'].hp == '01050222736') representative_number = '15221001';  // 하태우
                if(map['employeeVo'].hp == '01054041964') representative_number = '15221001';  // 이정훈
                if(map['employeeVo'].hp == '01051004912') representative_number = '15221001';  // 2018.04.24.왕윤진
                if(map['employeeVo'].hp == '01093460488') representative_number = '15221001';  // 2019.11.22.조영진

                if(map['employeeVo'].hp == '01084342955') fax_number = '05040992955';
                if(map['employeeVo'].hp == '01067128555') fax_number = '05040992955';
                if(map['employeeVo'].hp == '01031388303') fax_number = '0518043023';


                var tags = new Array();

                if(representative_number != '') {
                    tags.push('<option value1="15221001" value2="'+ map['employeeVo'].name +'">1522-1001 [사랑모아금융서비스 대표번호]</option>');
                }

                //ERP정보 등록된거 뿌리는 부분. 주석풀면 위에 만들어놓은 노가다 지워도 되는 부분
//         if(map['employeeVo'].officeTel != ''){
//          tags.push('<option value1="'+ map['employeeVo'].officeTel.replace('-','') +'" value2="'+ map['employeeVo'].name +'">'+ map['employeeVo'].officeTel +' [내선번호]</option>');
//         }

                if(inner_number != ''){
                    tags.push('<option value1="'+ inner_number +'" value2="'+ map['employeeVo'].name +'">'+ getPhoneFormat(1, inner_number) +' [내선번호]</option>');
                }

                if(fax_number != ''){
                    tags.push('<option value1="'+ fax_number +'" value2="'+ map['employeeVo'].name +'">'+ getPhoneFormat(1, fax_number) +' [팩스번호]</option>');
                }

                tags.push('<option value1="'+ map['employeeVo'].hp +'" value2="'+ map['employeeVo'].name +'">'+ getPhoneFormat(1, map['employeeVo'].hp) +' ['+ map['employeeVo'].codeSeq6Name +' '+ map['employeeVo'].name +']</option>');
                jQuery('#sender'+paramDivision).html(tags.join(''));
            });
        }
        /*******************************************************************************************
         * 문자발송 - 사원조회 셀렉트 박스 생성
         *******************************************************************************************/
        function bizMsgEmployeeInit(){
            var division = (paramDivision-2);
            employeeDwr.popupInit(function(map){
                // 소속/직급
                var selCodeSeq2 = document.getElementsByName('codeSeq2')[0];
                var selCodeSeq6 = document.getElementsByName('codeSeq6')[0];
                var selCodeSeq101 = document.getElementsByName('codeSeq101')[0];
                var selCodeSeq102 = document.getElementsByName('codeSeq102')[0];

                selCodeSeq2.options[selCodeSeq2.options.length]= new Option('지점', -1);
                selCodeSeq6.options[selCodeSeq6.options.length]= new Option('본부', -1);
                selCodeSeq101.options[selCodeSeq101.options.length]= new Option('직급', -1);
                selCodeSeq102.options[selCodeSeq102.options.length]= new Option('직무', -1);
                for(var i = 0 ; i < map['listCodeVo'].length ; i++)
                {
                    if(map['listCodeVo'][i].division == 101)
                        selCodeSeq101.options[selCodeSeq101.options.length]= new Option(map['listCodeVo'][i].name, map['listCodeVo'][i].codeSeq);
                    else if(map['listCodeVo'][i].division == 102)
                        selCodeSeq102.options[selCodeSeq102.options.length]= new Option(map['listCodeVo'][i].name, map['listCodeVo'][i].codeSeq);
                    else if(map['listCodeVo'][i].division == 6)
                        selCodeSeq6.options[selCodeSeq6.options.length]= new Option(map['listCodeVo'][i].name, map['listCodeVo'][i].codeSeq);
                }

                for(var i = 0 ; i < map['listCodeVo2'].length ; i++)
                {
                    selCodeSeq2.options[selCodeSeq2.options.length]= new Option(map['listCodeVo2'][i].name, map['listCodeVo2'][i].codeSeq);
                }

                selCodeSeq2[0].selected = true;
                selCodeSeq6[0].selected = true;
                selCodeSeq101[0].selected = true;
                selCodeSeq102[0].selected = true;
                document.getElementsByName('isRetirement')[0][1].selected = true;
                document.getElementsByName('employee_name')[0].value = '';

                bizMsgEmployeeSearch();
            });
        }
        /*******************************************************************************************
         * 문자발송 - 사원조회
         *******************************************************************************************/
        function bizMsgEmployeeSearch()
        {
            var division = (paramDivision-2);
            jQuery.myDialog.loading('조회 중입니다...');
            var employeeParamVo =
                {
                    pageSize        : 99999,
                    currentPage     : 1,
                    //나중에 name 값에 paramDivision넣어서 찾아주면됨 그렇게 되면 공통사용가능
                    codeSeq6        : document.getElementsByName('codeSeq6')[division].value,
                    codeSeq2        : document.getElementsByName('codeSeq2')[division].value,
                    codeSeq101      : document.getElementsByName('codeSeq101')[division].value,
                    codeSeq102      : document.getElementsByName('codeSeq102')[division].value,
                    name            : document.getElementsByName('employee_name')[division].value,
                    isRetirement    : document.getElementsByName('isRetirement')[division].value
                };
            employeeDwr.listPopup(employeeParamVo, function(map)
            {
                var tags = new Array();
                var count = 0;
                var all_count = 0;
                for (var i = 0 ; i < map['listEmployeePopupVo'].length ; i++)
                {
                    if(map['listEmployeePopupVo'][i].hp.replace(/\-/g,'').trim() != ''){
                        count++;
                        tags.push('<li style="cursor:pointer;" onclick="bizMsgAddDest(\'employee_'+ map['listEmployeePopupVo'][i].id +'\')">');
                        if(bizMsgCompare('employee_' + map['listEmployeePopupVo'][i].id) > 0){
                            all_count++;
                            tags.push(' <span class="checkbox"><input checked="checked" type="checkbox" id="employee_' + map['listEmployeePopupVo'][i].id + '" name="checkbox_'+ paramDivision +'_1" value1="사원" value2="' + map['listEmployeePopupVo'][i].name + '" value3="' + getPhoneFormat(1, map['listEmployeePopupVo'][i].hp) + '"> <label for="ex_' + i + '"></label></span>');
                        }else{
                            tags.push(' <span class="checkbox"><input type="checkbox" id="employee_' + map['listEmployeePopupVo'][i].id + '" name="checkbox_'+ paramDivision +'_1" value1="사원" value2="' + map['listEmployeePopupVo'][i].name + '" value3="' + getPhoneFormat(1, map['listEmployeePopupVo'][i].hp) + '"> <label for="ex_' + i + '"></label></span>');
                        }
                        tags.push(' <span class="num">' + count + '</span>');
                        tags.push(' <span class="code">' + map['listEmployeePopupVo'][i].id + '</span>');
                        tags.push(' <span class="name">' + map['listEmployeePopupVo'][i].name + '</span>');
                        tags.push(' <span class="office">' + (map['listEmployeePopupVo'][i].codeSeq2Name == '9본 지점' ? '본점소속' : map['listEmployeePopupVo'][i].codeSeq2Name) + '</span>');
                        tags.push(' <span class="phone">' + getPhoneFormat(1, map['listEmployeePopupVo'][i].hp.replace(/\-/g,'').trim()) + '</span>');
                        tags.push('</li>');
                    }
                }
                jQuery('#bizMsg_employee_listArea'+paramDivision).html(tags.join(''));

                if(count == 1){
                    bizMsgSelectAll(0);
                    document.getElementsByName('employee_name')[0].value = '';
                }else if(all_count == count && count != 0){
                    document.getElementById('all_'+ paramDivision +'_1').checked = true;
                }else{
                    document.getElementById('all_'+ paramDivision +'_1').checked = false;
                }

                jQuery.myDialog.hide();
            });
        }
        /*******************************************************************************************
         * 문자발송 - 유망고객 조회
         *******************************************************************************************/
        function bizMsgRelationSearch()
        {
            jQuery.myDialog.loading('조회 중입니다...');
            var relationParamVo =
                {
                    pageSize    : 99999,
                    currentPage : 1,
                    groupSeq    : '',
                    name        : '',
                    hp          : '',
                    id          : setId,
                    type        : '2'
                };
            //알림톡 추가시 division -2 -> -1 로 바꿀예정
            var division = (paramDivision-2);
            if(division != 1){
                relationParamVo.name = document.getElementsByName('relation_name')[division].value;
                relationParamVo.hp = document.getElementsByName('relation_hp')[division].value;
            }

            relationDwr.list(relationParamVo, function(map)
            {
                var tags = new Array();
                var count = 0;
                if(paramDivision == 3){
                    for (var i = 0 ; i < map['listRelationListVo'].length ; i++) {
                        if(map['listRelationListVo'][i].fax.replace(/\-/g,'').trim() != ''){
                            count++;
                            tags.push('<li style="cursor:pointer;" onclick="bizMsgAddDest(\'relation_fax'+ map['listRelationListVo'][i].crmCode +'\')">');
                            if(bizMsgCompare('relation_'+ map['listRelationListVo'][i].crmCode) > 0){
                                tags.push(' <span class="checkbox"><input checked="checked" type="checkbox" name="checkbox_'+ paramDivision +'_1" id="relation_fax'+ map['listRelationListVo'][i].crmCode +'" value1="유망고객" value2="'+ map['listRelationListVo'][i].name +'" value3="'+ getPhoneFormat(1, map['listRelationListVo'][i].fax) +'"> <label for="ex_'+ i +'"></label></span>');
                            }else{
                                tags.push(' <span class="checkbox"><input type="checkbox" name="checkbox_'+ paramDivision +'_1" id="relation_fax'+ map['listRelationListVo'][i].crmCode +'" value1="유망고객" value2="'+ map['listRelationListVo'][i].name +'" value3="'+ getPhoneFormat(1, map['listRelationListVo'][i].fax) +'"> <label for="ex_'+ i +'"></label></span>');
                            }
                            tags.push(' <span class="num">' + count + '</span>');
                            tags.push(' <span class="company">'+ map['listRelationListVo'][i].companyName +'</span>');
                            tags.push(' <span class="name" title="' + map['listRelationListVo'][i].name + '">' + map['listRelationListVo'][i].name + '</span>');
                            tags.push(' <span class="fax">' + getPhoneFormat(1, map['listRelationListVo'][i].fax.replace(/\-/g,'').trim()) + '</span>');
                            tags.push('</li>');
                        }
                    }
                }else{
                    for (var i = 0 ; i < map['listRelationListVo'].length ; i++) {
                        if(map['listRelationListVo'][i].hp.replace(/\-/g,'').trim() != ''){
                            count++;
                            tags.push('<li style="cursor:pointer;" onclick="bizMsgAddDest(\'relation_'+ map['listRelationListVo'][i].crmCode +'\')">');
                            if(bizMsgCompare('relation_'+ map['listRelationListVo'][i].crmCode) > 0){
                                tags.push(' <span class="checkbox"><input checked="checked" type="checkbox" name="checkbox_'+ paramDivision +'_2" id="relation_'+ map['listRelationListVo'][i].crmCode +'" value1="유망고객" value2="'+ map['listRelationListVo'][i].name +'" value3="'+ getPhoneFormat(1, map['listRelationListVo'][i].hp) +'"> <label for="ex_'+ i +'"></label></span>');
                            }else{
                                tags.push(' <span class="checkbox"><input type="checkbox" name="checkbox_'+ paramDivision +'_2" id="relation_'+ map['listRelationListVo'][i].crmCode +'" value1="유망고객" value2="'+ map['listRelationListVo'][i].name +'" value3="'+ getPhoneFormat(1, map['listRelationListVo'][i].hp) +'"> <label for="ex_'+ i +'"></label></span>');
                            }
                            tags.push(' <span class="num">' + count + '</span>');
                            tags.push(' <span class="name" title="' + map['listRelationListVo'][i].name + '">' + map['listRelationListVo'][i].name + '</span>');
                            tags.push(' <span class="resident">' + map['listRelationListVo'][i].sn + '</span>');
                            tags.push(' <span class="phone">' + getPhoneFormat(1, map['listRelationListVo'][i].hp.replace(/\-/g,'').trim()) + '</span>');
                            tags.push('</li>');
                        }
                    }
                }
                jQuery('#bizMsg_relation_listArea'+paramDivision).html(tags.join(''));
                jQuery.myDialog.hide();
            });
        }
        /*******************************************************************************************
         * 계약고객 검색
         *******************************************************************************************/
        function bizMsgMemberSearch()
        {
            jQuery.myDialog.loading('조회 중입니다...');
            var division = (paramDivision-2);
            var insureMemberParamVo =
                {
                    pageSize        : 99999,
                    currentPage     : 1,
                    name            : document.getElementsByName('member_name')[division].value,
                    hp              : document.getElementsByName('member_hp')[division].value
                };

            insureCommonDwr.listMember(insureMemberParamVo, function(map)
            {
                var divisionName = '';
                var tags = new Array();
                var count = 0;
                for (var i = 0 ; i < map['listInsureMemberVo'].length ; i++)
                {
                    if(map['listInsureMemberVo'][i].hp.replace(/\-/g,'').trim() != ''){
                        count++;
                        switch(map['listInsureMemberVo'][i].division)
                        {
                            case 1 : divisionName = '생보';   break;
                            case 2 : divisionName = '손보';   break;
                            case 3 : divisionName = '자동차';  break;
                            case 4 : divisionName = '일반';   break;
                        }
                        tags.push('<li style="cursor:pointer;" onclick="bizMsgAddDest(\'member_'+ divisionName + map['listInsureMemberVo'][i].num +'\')">');
                        if(bizMsgCompare('member_'+ divisionName + map['listInsureMemberVo'][i].num) > 0){
                            tags.push(' <span class="checkbox"><input checked="checked" type="checkbox" id="member_'+ divisionName + map['listInsureMemberVo'][i].num +'" name="checkbox'+ paramDivision +'_3" value1="계약고객" value2="'+ map['listInsureMemberVo'][i].name +'" value3="'+ getPhoneFormat(1, map['listInsureMemberVo'][i].hp.replace(/\-/g,'')) +'"> <label for="ex_'+ i +'"></label></span>');
                        }else{
                            tags.push(' <span class="checkbox"><input type="checkbox" id="member_'+ divisionName + map['listInsureMemberVo'][i].num +'" name="checkbox_'+ paramDivision +'_3" value1="계약고객" value2="'+ map['listInsureMemberVo'][i].name +'" value3="'+ getPhoneFormat(1, map['listInsureMemberVo'][i].hp.replace(/\-/g,'')) +'"> <label for="ex_'+ i +'"></label></span>');
                        }
                        tags.push(' <span class="num">' + count + '</span>');
                        tags.push(' <span class="insurance">' + divisionName + '</span>');
                        tags.push(' <span class="produc">' + map['listInsureMemberVo'][i].codeInsureName.cut(20) + '</span>');
                        tags.push(' <span class="name">' + map['listInsureMemberVo'][i].name.cut(12) + '</span>');
                        tags.push(' <span class="phone">' + getPhoneFormat(1, map['listInsureMemberVo'][i].hp.replace(/\-/g,'').trim()) + '</span>');
                        tags.push('</li>');
                    }
                }
                $('#bizSms_member_listArea').html(tags.join(''));
                jQuery.myDialog.hide();
            });
        }
        /*******************************************************************************************
         * 팩스 주소록 검색
         *******************************************************************************************/
        function bizMsgFaxAddressSearch(){
            bizMsgSrmoaDwr.bizAddressList(function(map){
                if(map['errorMessage'] == null){
                    jQuery.myDialog.loading('조회 중입니다...');
                    var tags = new Array();
                    for (var i = 0 ; i < map['bizAddressList'].length ; i++){
                        tags.push('<li style="cursor:pointer;" onclick="bizMsgAddDest(\'address_'+ map['bizAddressList'][i].address_seq +'\')">');
                        if(bizMsgCompare('address_' + map['bizAddressList'][i].address_seq) > 0){
                            tags.push(' <span class="checkbox"><input type="checkbox" id="address_'+ map['bizAddressList'][i].address_seq +'" name="checkbox_'+ paramDivision +'_3" value1="주소록" value2="'+ map['bizAddressList'][i].DEST_NAME +'" value3="'+ getPhoneFormat(1, map['bizAddressList'][i].DEST_PHONE.replace(/\-/g,'')) +'"><label for="ex_'+ i +'"></label></span>');
                        }else{
                            tags.push(' <span class="checkbox"><input type="checkbox" id="address_'+ map['bizAddressList'][i].address_seq +'" name="checkbox_'+ paramDivision +'_3" value1="주소록" value2="'+ map['bizAddressList'][i].DEST_NAME +'" value3="'+ getPhoneFormat(1, map['bizAddressList'][i].DEST_PHONE.replace(/\-/g,'')) +'"><label for="ex_'+ i +'"></label></span>');
                        }
                        tags.push(' <span class="num">'+ (i+1) +'</span>');
                        tags.push(' <span class="name" title="' + map['bizAddressList'][i].DEST_NAME + '">' + map['bizAddressList'][i].DEST_NAME + '</span>');
                        tags.push(' <span class="fax">' + getPhoneFormat(1, map['bizAddressList'][i].DEST_PHONE.replace(/\-/g,'').trim()) + '</span>');
                        tags.push(' <span class="btn"><a style="cursor:pointer;" onclick="bizAddressDelete('+ map['bizAddressList'][i].address_seq +');">X</a></span>');
                        tags.push('</li>');
                    }
                    $('#bizMsg_address_listArea3').html(tags.join(''));
                    jQuery.myDialog.hide();
                }else{
                    jQuery.myDialog.error(map['errorMessage']);
                }
            });

        }
        /*******************************************************************************************
         * 팩스 주소 삭제
         *******************************************************************************************/
        function bizAddressDelete(seq){
            event.stopPropagation();
            bizMsgSrmoaDwr.bizAddressDelete(seq, function(map){
                if(map['errorMessage'] != null){
                    jQuery.myDialog.error(map['errorMessage']);
                }else{
                    document.getElementById('address_'+seq).parentNode.parentNode.remove();
                    $('#dest_address_'+seq).remove();
                }
                var addressListElement = document.getElementById('bizMsg_address_listArea'+paramDivision);
                var i = 0;
                Array.from(addressListElement.querySelectorAll('li')).forEach(li => {
                    li.getElementsByClassName('num')[0].innerHTML = ++i;
                });
                if(i == 0){
                    document.getElementById('all_'+ paramDivision +'_3').checked = false;

                }
            });
        }
        /*******************************************************************************************
         * 엑셀등록
         *******************************************************************************************/
        var rABS = true; // T : 바이너리, F : 어레이 버퍼

        // 어레이 버퍼를 처리한다 ( 오직 readAsArrayBuffer 데이터만 가능하다 )
        function fixdata(data) {
            var o = "", l = 0, w = 10240;
            for(; l<data.byteLength/w; ++l) o+=String.fromCharCode.apply(null,new Uint8Array(data.slice(l*w,l*w+w)));
            o+=String.fromCharCode.apply(null, new Uint8Array(data.slice(l*w)));
            return o;
        }
        //데이터를 바이너리 스트링으로 얻는다.
        function getConvertDataToBin($data){
            var arraybuffer = $data;
            var data = new Uint8Array(arraybuffer);
            var arr = new Array();
            for(var i = 0; i != data.length; ++i) arr[i] = String.fromCharCode(data[i]);
            var bstr = arr.join("");

            return bstr;
        }
        function handleFile(e) {
            var files = e.target.files;
            var i,f;
            for (i = 0; i != files.length; ++i) {
                f = files[i];
                var reader = new FileReader();
                var name = f.name;

                reader.onload = function(e) {
                    var data = e.target.result;

                    var workbook;

                    if(rABS) {
                        /* if binary string, read with type 'binary' */
                        try{
                            workbook = XLSX.read(data, {type: 'binary'});
                        }catch(error){
                            workbook = 0;
                            document.getElementById('fileName'+paramDivision).value = '등록 불가능한 형식의 파일입니다.';
                            alert('등록 불가능한 형식의 파일입니다.');
                        }
                    } else {
                        /* if array buffer, convert to base64 */
                        var arr = fixdata(data);
                        try{
                            workbook = XLSX.read(btoa(arr), {type: 'base64'});
                        }catch(error){
                            workbook = 0;
                            document.getElementById('fileName'+paramDivision).value = '등록 불가능한 형식의 파일입니다.';
                            alert('등록 불가능한 형식의 파일입니다.');
                        }
                    }//end. if

                    //excel_seq 값 가져오기
                    var excel_seq = 0;
                    for(var i = 0 ; i < document.getElementById('bizMsgDestArea'+paramDivision).getElementsByTagName('li').length ; i++){
                        if(document.getElementById('bizMsgDestArea'+paramDivision).getElementsByTagName('li')[i].id.indexOf('excel') != -1){
                            excel_seq++;
                        }
                    }

                    /* 워크북 처리 */
                    if(workbook != 0){
                        workbook.SheetNames.forEach(function(item, index, array) {
                            var csv = XLSX.utils.sheet_to_csv(workbook.Sheets[item],{RS:'|'});
                            var split = csv.split('|');
                            $.each(split, function(index, item){
                                if(index == 0){
                                    var item_split = item.split(',');
                                    if(item_split[0] != '이름' || item_split[1] != '전화번호'){
                                        document.getElementById('fileName'+paramDivision).value = '파일이 형식에 맞지 않습니다.';
                                        alert('파일이 형식에 맞지 않습니다.');
                                        return false;
                                    }
                                }else{
                                    if(item != ''){
                                        var item_split = item.split(',');
                                        if(item_split.length != 2) {
                                            document.getElementById('fileName'+paramDivision).value = '파일이 형식에 맞지 않습니다.';
                                            alert('파일이 형식에 맞지 않습니다.');
                                            return false;
                                        }else{
                                            if(item_split[0] != '' && item_split[1] != ''){
                                                document.getElementById('fileName'+paramDivision).value = document.getElementById('file'+paramDivision).value;
                                                excel_seq++
                                                var excel_idx = 'excel_'+excel_seq;
                                                var cate = '엑셀등록';
                                                var name = item_split[0];
                                                var phone = item_split[1];
                                                $('#bizMsgDestArea'+paramDivision).append(
                                                    '<li id="dest_' + excel_idx + '">'
                                                    + '<span class="num">1</span>'
                                                    + '<span class="cate">'+ cate +'</span>'
                                                    + '<span class="name">' + name + '</span>'
                                                    + '<span class="phone">' + phone + '</span>'
                                                    + '<a href="#" onclick="bizMsgRemoveDest(\'' + excel_idx + '\');">x</a>'
                                                    +'</li>'
                                                );
//                                         bizMsgAddDest(index+','+item, 4);
                                            }else{
                                                alert('이름 또는 전화번호가 입력되지 않았습니다.');
                                            }

                                        }
                                    }
                                }
                            });
                        });//end. forEach
                    }
                    overlapRemoveAll();
                    destCount();
                }; //end onload
                if(rABS) reader.readAsBinaryString(f);
                else reader.readAsArrayBuffer(f);
            }//end. for
        }
        /*******************************************************************************************
         * 직접등록
         *******************************************************************************************/
        function registerByTypingInit(division){
            $('#registerByTyping'+division).empty();
            if(division == 2){
                for(var i = 1; i<=30; i++){
                    $('#registerByTyping'+division).append(
                        '<li id=register_'+ paramDivision +'_'+ i +'>'
                        +  '<span class="num">'+ i +'</span>'
                        +  '<input class="name" id="register_name'+ division +'_'+ i +'" type="text" placeholder="이름">'
                        +  '<input class="phone" id="register_phone'+ division +'_'+ i +'" type="phone" placeholder="휴대폰번호(ex:01012345678)" maxlength="13" onKeyup="this.value=this.value.replace(/-/gi,\'\');"'
                        + '</li>'
                    );
                }
            }else if(division == 3){
                for(var i = 1; i <=30 ; i++){
                    $('#registerByTyping'+division).append(
                        '<li id=register_'+ paramDivision +'_'+ i +'>'
                        +  '<span class="num">'+ i +'</span>'
                        +  '<input class="name" id="register_name'+ division +'_'+ i +'" type="text" placeholder="담당자">'
                        +  '<input class="phone" id="register_phone'+ division +'_'+ i +'" type="phone" placeholder="팩스번호(ex:05012345678)" maxlength="13" onKeyup="this.value=this.value.replace(/-/gi,\'\');"'
                        + '</li>'
                    );
                }
            }
        }
        function registerByTyping(idx, e){
            var name = document.getElementById('register_name'+ paramDivision +'_'+ idx).value;
            var phone = getPhoneFormat(1 ,document.getElementById('register_phone'+ paramDivision +'_'+ idx).value);
            if(document.getElementById('dest_register_'+ paramDivision +'_'+idx) == null){
                $('#bizMsgDestArea'+paramDivision).append(
                    '<li id="dest_register_'+ paramDivision +'_'+ idx + '">'
                    +' <span class="num">1</span>'
                    +' <span class="cate">직접입력</span>'
                    +' <span class="name" title="' + name + '">' + name + '</span>'
                    +' <span class="' + (paramDivision == 3 ? 'fax' : 'phone') + '">' + phone + '</span>'
                    +' <a href="#" onclick="bizMsgRemoveDest(\'register_'+ paramDivision +'_'+ idx + '\');">x</a>'
                    +'</li>'
                );
                $('#bizMsgDestScroll'+paramDivision).stop().animate({scrollTop:$('#bizMsgDestArea'+paramDivision).height()},400);
            }else{
                $('#dest_register_'+ paramDivision +'_'+idx).replaceWith(
                    '<li id="dest_register_'+ paramDivision +'_'+ idx + '">'
                    +' <span class="num">1</span>'
                    +' <span class="cate">직접입력</span>'
                    +' <span class="name" title="' + name + '">' + name + '</span>'
                    +' <span class="' + (paramDivision == 3 ? 'fax' : 'phone') + '">' + phone + '</span>'
                    +' <a href="#" onclick="bizMsgRemoveDest(\'register_'+ paramDivision +'_'+ idx + '\');">x</a>'
                    +'</li>'
                );
            }
            if(phone.length == 12 || phone.length == 13){
                var overlap_result = overlapRemove('register_'+ paramDivision +'_'+idx);
                if(overlap_result != 0){
                    alert("중복된 연락처가 있습니다.");
                }
            }
            if(phone == '' && name == '' && e == 8){
                bizMsgRemoveDest('register_'+ paramDivision +'_'+idx);
            }
            destCount();
        }
        /*******************************************************************************************
         * 수신 리스트 <-> 조회 리스트 비교 연산
         *******************************************************************************************/
        function bizMsgCompare(idx){
            var compare_result = 0;
            var bizMsgDestArea = document.getElementById('bizMsgDestArea'+paramDivision);
            if(paramDivision == 2){
                Array.from(bizMsgDestArea.querySelectorAll('li')).forEach(li => {
                    if(li.id == 'dest_'+idx){
                        compare_result++
                    }
                });
            }
            return compare_result;
        }
        /*******************************************************************************************
         * 전체 추가 - 일반
         *******************************************************************************************/
        function bizMsgSelectAll(select_division)
        {
            var tab_id = document.getElementById('bizMsgArea'+paramDivision).getElementsByClassName('on')[0].id;
            var tab_division = tab_id.substr(tab_id.length-1);
            var size = document.getElementsByName('checkbox_'+ paramDivision +'_'+tab_division).length;
            if(select_division == 0){
                document.getElementById('all_'+paramDivision+'_'+tab_division).checked = true;
            }
            if(document.getElementById('all_'+paramDivision+'_'+tab_division).checked == true){
                for(var i = 0 ; i < size ; i++){
                    document.getElementsByName('checkbox_'+ paramDivision +'_'+tab_division)[i].checked = true;
                    $('#bizMsgDestArea'+paramDivision).append(
                        '<li id="dest_' + document.getElementsByName('checkbox_'+ paramDivision +'_'+tab_division)[i].id + '">'
                        + '<span class="num">1</span>'
                        + (paramDivision == 3 ? '<span class="company">' : '<span class="cate">') + document.getElementsByName('checkbox_'+ paramDivision +'_'+tab_division)[i].getAttribute('value1') + '</span>'
                        + '<span class="name" title="' + document.getElementsByName('checkbox_'+ paramDivision +'_'+tab_division)[i].getAttribute('value2') + '">' + document.getElementsByName('checkbox_'+ paramDivision +'_'+tab_division)[i].getAttribute('value2') + '</span>'
                        + (paramDivision == 3 ? '<span class="fax">' : '<span class="phone">') + document.getElementsByName('checkbox_'+ paramDivision +'_'+tab_division)[i].getAttribute('value3') + '</span>'
                        + '<a href="#" onclick="bizMsgRemoveDest(\'' + document.getElementsByName('checkbox_'+ paramDivision +'_'+tab_division)[i].id + '\');">x</a>'
                        +'</li>'
                    );
                }
                overlapRemoveAll();
                destCount();
            }else{
                for(var i = 0 ; i < size ; i++){
                    document.getElementsByName('checkbox_'+ paramDivision +'_'+tab_division)[i].checked = false;
                    var idx = document.getElementById('dest_' + document.getElementsByName('checkbox_'+ paramDivision +'_'+tab_division)[i].id);
                    if(idx != null){
                        document.getElementById('bizMsgDestArea'+paramDivision).removeChild(idx);
                    }
                }
                destCount();
            }
        }
        /*******************************************************************************************
         * 수신자 추가 - 일반
         *******************************************************************************************/
        function bizMsgAddDest(idx){
            if(document.getElementById(idx).checked == false){
                document.getElementById(idx).checked = true;
                var all_check = 0;
                var cate = document.getElementById(idx).getAttribute('value1');
                var all_number;
                cate == '사원' ? all_number = 1 : cate == '유망고객' ? paramDivision == 3 ? all_number = 1 :all_number = 2 : cate == '계약고객' ? all_number = 3 : cate == '주소록' ? all_number = 3 : '';
                for(var i = 0 ; i < document.getElementsByName('checkbox_'+ paramDivision +'_'+all_number).length ; i++){
                    if(document.getElementsByName('checkbox_'+ paramDivision +'_'+all_number)[i].checked == false){
                        all_check++;
                    }
                }
                if(all_check == 0){
                    document.getElementById('all_'+ paramDivision +'_'+all_number).checked = true;
                }

                var name = document.getElementById(idx).getAttribute('value2');
                var phone = document.getElementById(idx).getAttribute('value3');
                if(overlapRemove(idx) == 0){
                    $('#bizMsgDestArea'+paramDivision).append(
                        '<li id="dest_' + idx + '">'
                        + '<span class="num">1</span>'
                        + '<span class="cate">' + cate + '</span>'
                        + '<span class="name" title="' + name + '">' + name + '</span>'
                        + '<span class="'+ (paramDivision == 3 ? 'fax' : 'phone') +'">' + phone + '</span>'
                        + '<a href="#" onclick="bizMsgRemoveDest(\'' + idx + '\');">x</a>'
                        +'</li>'
                    );
                }else if(overlapRemove(idx) != 0){
                    alert('중복된 연락처가 있습니다.');
                }
            }else if(document.getElementById(idx).checked == true){
                bizMsgRemoveDest(idx);
            }
            destCount();
        }
        /*******************************************************************************************
         * 중복 제거
         *******************************************************************************************/
        function overlapRemove(idx){
            var compare_result = 0;
            var bizMsgDestArea = document.getElementById('bizMsgDestArea'+paramDivision);
            Array.from(bizMsgDestArea.querySelectorAll('li')).forEach(li => {
                if(li.id != 'dest_'+idx){
                    var compare_phone = typeof(li.getElementsByClassName('phone')[0]) == 'undefined' ? li.getElementsByClassName('fax')[0].innerHTML : li.getElementsByClassName('phone')[0].innerHTML;
                    var idx_phone;
                    if(document.getElementById('dest_'+idx) != null){
                        idx_phone = typeof(document.getElementById('dest_'+idx).getElementsByClassName('phone')[0]) == 'undefined' ? document.getElementById('dest_'+idx).getElementsByClassName('fax')[0].innerHTML : document.getElementById('dest_'+idx).getElementsByClassName('phone')[0].innerHTML;
                    }else{
                        idx_phone = document.getElementById(idx).getAttribute('value3');
                    }
                    if(compare_phone == idx_phone && compare_phone != ''){
                        compare_result++;
                    };
                }
            });
            return compare_result;
        }
        /*******************************************************************************************
         * 일괄 중복 제거
         *******************************************************************************************/
        function overlapRemoveAll(){
            var bizMsgDestArea = document.getElementById('bizMsgDestArea'+paramDivision);
            var size = bizMsgDestArea.getElementsByTagName('li').length;
            var ival;
            var jval;
            var del_count = 0;
            for(var i = 0 ; i < (size-1)-del_count ; i++){
                ival = bizMsgDestArea.getElementsByTagName('li')[i].getElementsByClassName(paramDivision == 3 ? 'fax' : 'phone')[0].innerHTML;
                for(var j = i + 1 ; j < size-del_count ; j++){
                    jval = bizMsgDestArea.getElementsByTagName('li')[j].getElementsByClassName(paramDivision == 3 ? 'fax' : 'phone')[0].innerHTML;
                    if(ival == jval){
                        del_count++;
                        bizMsgDestArea.removeChild(bizMsgDestArea.getElementsByTagName('li')[j]);
                    }
                }
            }
        }
        /*******************************************************************************************
         * 수신자 전체 삭제
         *******************************************************************************************/
        function bizMsgRemoveAllDest(){
            $('input[type=checkbox]').not($('[id^=reserve_chk]')).attr("checked","");
            $('input[id^=register]').val('');
            $('input[name=fileName'+ paramDivision +']').val('선택된 파일이 없습니다. 엑셀파일을 선택해주세요.');
            $('#bizMsgDestArea'+paramDivision).empty();
            $('#destCount'+paramDivision).text('0');
        }
        /*******************************************************************************************
         * 수신자 선택 삭제
         *******************************************************************************************/
        function bizMsgRemoveDest(idx){
            if(idx.indexOf('register') != -1){
                var number = idx.substr(idx.length - 1)
                document.getElementById('register_'+ paramDivision +'_'+number).getElementsByClassName('name')[0].value = '';
                document.getElementById('register_'+ paramDivision +'_'+number).getElementsByClassName('phone')[0].value = '';
                $('#bizMsgDestScroll'+paramDivision).stop().animate({scrollTop:$('#bizMsgDestArea'+paramDivision).height()},400);
            }else if(idx.indexOf('employee') != -1 && document.getElementById(idx) != null){
                document.getElementById('all_'+ paramDivision +'_1').checked = false;
                document.getElementById(idx).checked = false;
            }else if(idx.indexOf('relation') != -1 && document.getElementById(idx) != null){
                if(paramDivision == 3){
                    document.getElementById('all_'+ paramDivision +'_1').checked = false;
                    document.getElementById(idx).checked = false;
                }else{
                    document.getElementById('all_'+ paramDivision +'_2').checked = false;
                    document.getElementById(idx).checked = false;
                }
            }else if(idx.indexOf('member') != -1 && document.getElementById(idx) != null){
                document.getElementById('all_'+ paramDivision +'_3').checked = false;
                document.getElementById(idx).checked = false;
            }else if(idx.indexOf('address') != -1 && document.getElementById(idx) != null){
                document.getElementById('all_'+ paramDivision +'_3').checked = false;
                document.getElementById(idx).checked = false;
            };
            $('#dest_'+idx).remove();
            destCount();
        }
        /*******************************************************************************************
         * 수신자 카운트
         *******************************************************************************************/
        function destCount(){
            var size = document.getElementById('bizMsgDestArea'+paramDivision).getElementsByTagName('li').length;
            document.getElementById('destCount'+paramDivision).innerHTML = size;
            for(var i = 0 ; i < size ; i++){
                document.getElementById('bizMsgDestArea'+paramDivision).getElementsByTagName('li')[i].getElementsByClassName('num')[0].innerHTML = i+1;
            }
        }
        /*******************************************************************************************
         * 예약 시간 생성
         *******************************************************************************************/
        function reservationDateInit(division){
            //다른 페이지 생성되면 division 값을 날짜 뒤에 넣는다 그전에는 일단 2번으로 설정함
            initYearSelectBox(document.getElementsByName('year'+paramDivision)[0]);
            initMonthSelectBox(document.getElementsByName('month'+paramDivision)[0]);
            initDaySelectBox(document.getElementsByName('day'+paramDivision)[0])
            initHourSelectBox(document.getElementsByName('hour'+paramDivision)[0]);
            initMinuteSelectBox(document.getElementsByName('min'+paramDivision)[0]);

            document.getElementById('reserve_text'+paramDivision).innerHTML = '';
            document.getElementById('reserve_chk'+paramDivision).checked = false;

            var date = new Date();

            var day = date.getDate();
            var hour = date.getHours().toString();
            var min = date.getMinutes().toString();

            var min_plus = Number(min.substr(0,1) + '0') + 10;

            if(min_plus == 60){
                min_plus == 00;
                hour = Number(hour) + 1;
            }
            if(hour == 24){
                hour == 00;
                date.setDate(date.getDate() + 1);
            }
            selectbox_select(document.getElementsByName('year'+paramDivision)[0], date.getFullYear());
            selectbox_select(document.getElementsByName('month'+paramDivision)[0], (date.getMonth() + 1) > 9 ? '' + (date.getMonth() + 1) : '0' + (date.getMonth() + 1));
            selectbox_select(document.getElementsByName('day'+paramDivision)[0], date.getDate() > 9 ? '' + date.getDate() : '0' + date.getDate());
            selectbox_select(document.getElementsByName('hour'+paramDivision)[0], hour);
            selectbox_select(document.getElementsByName('min'+paramDivision)[0], min_plus);
        }
        function emoticonInit(){
            document.getElementById('emoticon_str1').value = '        ii   \n   ※┎iiii┑※\n ※┏♣~♡~♣┓※\n ┏"☆생★일☆"┓\n ~♡축하드립니다♡~';
            document.getElementById('emoticon_str2').value = '     *※ ♠ ※*\n    ※┎i■i┑※\n    ┏@@=♡=@@┓\n   ┏"☆생일☆"┓\n  * ♡축하해요♡ *';
            document.getElementById('emoticon_str3').value = '  .*""*   ζζζ\n  ┣━┫ ┓~~~ ┏\n  ┗━┛ ┗━━┛\n  따뜻한밥+미역국\n    ♣생일축하♣';
            document.getElementById('emoticon_str4').value = '  .:♡:생일:♡:.\n :♡축*~ii~*하♡:\n  :♡해▒▒요♡:\n    :♡LOVE♡:\n       ♡♡';
            document.getElementById('emoticon_str5').value = '    ┏┯@%@%@%@%@\n  ┏┛ㅁ┗@%@%@%\n  ┗⊙━━⊙♡┛=\n   ★결혼기념일\n   축하드립니다★';
            document.getElementById('emoticon_str6').value = '  #####    &&&&&\n  (^.^) ♡/(^.^)＼\n   ▶◀   "*@@*"\n    ★결혼기념일\n   축하드립니다★';
            document.getElementById('emoticon_str7').value = '  ♧♧♧♧♧♧\n ♧♧♧♧♧♧♧♧\n ＼결혼기념일♡／\n   ★★★★★★\n   축하드립니다';
            document.getElementById('emoticon_str8').value = '   ((♡^-^))\n ☆*:*고객님*::☆\n ☆*신규계약*::☆\n ☆*감사합니다*☆ \n ☆:*:♧**♧*::☆';
            document.getElementById('emoticon_str9').value = '  ♥ 신규계약 ♥\n ☆━━━━━━☆\n☆┃감사합니다┃☆\n ☆━━━━━━☆ \n    얍＼(^ㅡ^)ノ';
            document.getElementById('emoticon_str10').value = '  ♣♣♣♣♣♣♣\n    ♣ 고객님 ♣\n  ♣*:신규계약:*♣\n ♣*:감사합니다:*♣';
            document.getElementById('emoticon_str11').value = '   ※ * ♠ * ※\n  ※ *┎i■i┑*※\n  *┏@고객님♡@┓ \n ┏♡신규계약♡┓\n *감*사*합*니*다*';
            document.getElementById('emoticon_str12').value = '     ♡고객님♡\n  ☆━━━━━━☆\n  ┃신*규*계*약┃ \n  ☆━━━━━━☆\n  *감*사*합*니*다*';
            document.getElementById('emoticon_str13').value = '  ┏━━━━━━┓\n ┃1년계약유지┃\n  ┗━━━┳━━┛\n  △___△ \n =◑.◐= 감사합니다';
            document.getElementById('emoticon_str14').value = '  +     +     +\n   ＼ ☆│☆ ／\n+─☆1년☆계약☆─+\n ／ ☆유│지☆ ＼\n   ☆감사합니다☆';
            document.getElementById('emoticon_str15').value = '   .* * *.\n  *.*.*.*.* 1년계약\n  * * * * *   유지 \n   ＼^^ /    감사\n    /    ＼  합니다 ';
            document.getElementById('emoticon_str16').value = '  ~♥*" *^*" *♥~\n  * 1년♡ 계약*\n ♥♥♥유지♥♥♥\n  "*.감사합니다*"\n    " **^** " ';
            document.getElementById('emoticon_str17').value = '   /)/)    iiii\n  ( . .) ┏♡♡┓\n  ( づ♡┏☆""☆┓\n  ♡-1년☆계약-♡\n  유지 감사합니다!';
            document.getElementById('emoticon_str18').value = ' .*∴♡∵*.\n※♧@＠@♧※ 2년\n＼*@♧@♧@/계약유지\n  ＼☆^^☆/  감사\n   ▶◈◀~♪ 합니다';
            document.getElementById('emoticon_str19').value = '*"* *"* *"* *"\n☆*"2*"년*"☆\n☆*계*약*유*지*☆\n"*감*사*합*니*다*\n☆*☆*☆*☆*☆';
            document.getElementById('emoticon_str20').value = '*"* *"* *"* *"\n☆*"2*"년*"☆\n☆*계*약*유*지*☆\n"*감*사*합*니*다*\n☆*☆*☆*☆*☆';
            document.getElementById('emoticon_str21').value = '.*"♡:*..*"♡*.\n♡.＠♧2년♧＠.♡\n ♡.계약유지.♡\n  ♡.┍ⅲ┑.\n 감사합니다';
            document.getElementById('emoticon_str22').value = ' ξξξ  국화차 \n┃~**~┃┓한잔~\n┃*** ┃┛따뜻하게\n┃~**~┃  드세요';
            document.getElementById('emoticon_str23').value = '     ★   『복날』\n   ⊙◇⊙  삼계탕\n  ◀(♡)▶ 드시고\n    ￥￥  힘내세용~';
            document.getElementById('emoticon_str24').value = '♥경 축♥\n000본부\n00지점\n홍길동님\n종신000만원\n계약체결!\n얍＼(^ㅡ^)/';
        }
        /*******************************************************************************************
         * 예약 하기
         *******************************************************************************************/
        function reservation(division){
            var year = document.getElementsByName('year'+division)[0].value;
            var month = document.getElementsByName('month'+division)[0].value;
            var day = document.getElementsByName('day'+division)[0].value;
            var hour = document.getElementsByName('hour'+division)[0].value;
            var min = document.getElementsByName('min'+division)[0].value;
            var send_time = year+'-'+month+'-'+day+' '+hour+':'+min;
            $('#reserve_text'+division).empty().append(
                send_time+' 예약되었습니다. <a style="cursor:pointer;" onclick="reserveCancel('+division+')">X</a>'
            );
            document.getElementById('reserve_chk'+division).checked = true;
            document.getElementById('send_time'+division).value = send_time+':00';
            document.getElementById('reserve_popup'+division).style.display = 'none';
        }

        /*******************************************************************************************
         * 예약 취소
         *******************************************************************************************/
        function reserveCancel(division){
            document.getElementById('reserve_text'+division).innerHTML = '';
            document.getElementById('reserve_chk'+division).checked = false;
            document.getElementById('send_time'+division).value = '';
            document.getElementById('reserve_popup'+division).style.display = 'none';
        }
        /*******************************************************************************************
         * 파일 업로드 - 파일 아이프레임 서브밋
         *******************************************************************************************/
        function fileUpload(fileElement)
        {
            var fileSize = 0;
            var division = (paramDivision-2);
            var files = fileElement.files;
            var tempID = '';
            if(files.length > 50 && paramDivision == 3){
                jQuery.myDialog.error('50개 이상의 파일은 첨부 할 수 없습니다.');
                return false;
            }
            for(var i = 0 ; i < files.length ; i++){
                fileSize += fileElement.files[i].size;
                tempID += getTempID()+'/';
                var ext = files[i].name.substring((files[i].name).lastIndexOf('.') + 1).toLowerCase();
                if(paramDivision == 3){
                    if (!ext || !(/^(jpg|png|bmp|gif|doc|docx|xls|xlsx|ppt|pptx|hwp|pdf|txt|html)$/.test(ext))) {
                        jQuery.myDialog.error('지원하지 않는 확장자입니다.');
                        return false;
                    }
                }else{
                    if (!ext || !(/^(jpg|ma3|k3g)$/.test(ext))) {
                        jQuery.myDialog.error('이미지 파일만 업로드 가능합니다.<br /><br />(ex : jpg)');
                        return false;
                    }
                }
            }
            var sizeUnit = getManagedFileSize(fileSize).replace(/[^0-9]/g,"");
            var sizeType = getManagedFileSize(fileSize).replace(/[0-9]/g,"");
            if(sizeType == 'GB'){
                if(paramDivision != 3){
                    jQuery.myDialog.error('60KB 이상의 파일은 첨부 할 수 없습니다.');
                    return false;
                }
            }
            if(sizeType == 'MB' && paramDivision != 3){
                jQuery.myDialog.error('60KB 이상의 파일은 첨부 할 수 없습니다.');
                return false;
            }
            if(sizeUnit >= 60 && paramDivision != 3){
                if(sizeType == 'KB'){
                    jQuery.myDialog.error('60KB 이상의 파일은 첨부 할 수 없습니다.');
                    return false;
                }
            }
            document.getElementsByName('tempID')[division].value = tempID;
            var frm = jQuery(fileElement.form);
            frm.attr('action', '../controller/uploadMulti.jsp?formName='+frm.attr('name')+'&inputName='+fileElement+'&tempID='+tempID+'&fieldName='+fileElement.name);
            frm.attr("method", "post");
            frm.attr("enctype", "multipart/form-data");
            frm.attr("target", "fileFrame"+paramDivision);
//     jQuery.myDialog.loading('파일 업로드 중입니다...<br/><br/>파일 용량에 따라 업로드 시간이 길어지오니<br/>잠시 기다려 주시기 바랍니다.');
            frm.ajaxForm();
            frm.submit();
        }
        /*******************************************************************************************
         * 파일 업로드 - 결과
         *******************************************************************************************/
        function multiUpLoadResult(result){

            if(result == '1'){
                var division = (paramDivision-2);
                var fileElement = document.getElementById('bizMsg_fileElement'+paramDivision);
                if(fileElement.value.length < 1) return false;
                var frm = jQuery(fileElement.form);
                var tempID = document.getElementsByName('tempID')[division].value;
                var formName = frm.attr('name');
                var files = fileElement.files;
                var fileNames = new Array();
                for(var i = 0 ; i < files.length ; i++){
                    fileNames.push(files[i].name)
                }
                commonUploadDwr.getTempFileVoList(fileNames, tempID, formName, function(CommonTempFileVoList)
                {
                    document.getElementsByName('tempID')[division].value = '';

                    if($.browser.msie) {
                        $("#bizMsg_fileElement"+paramDivision).replaceWith($("#bizMsg_fileElement"+paramDivision).clone(true));
                    }else{
                        $("#bizMsg_fileElement"+paramDivision).val("");
                    }

                    bizMsgTempFileAddList(CommonTempFileVoList);
                });
            }else if(result == '-1'){
                jQuery.myDialog.hide();
                jQuery.myDialog.error('시스템 오류');
            }
        }
        /*******************************************************************************************
         * 파일업로드 - 임시 첨부파일 리스트(REG)에 추가
         *******************************************************************************************/
        var countTempFileId = 0;
        var totalFileSize = 0;
        function bizMsgTempFileAddList(CommonTempFileVoList)
        {
            if(CommonTempFileVoList.length != 0){
                $('#empty_file'+paramDivision).remove();
            }
            for(var i = 0 ; i < CommonTempFileVoList.length ; i++){
                countTempFileId++;
                totalFileSize += CommonTempFileVoList[i].fileSize;
                $('#add_file'+paramDivision).append(
                    '<li id="tempFileId' + countTempFileId + '" tempFile = "'+ CommonTempFileVoList[i].tempName +'">'
                    +' <a href="#none">'
                    +'  <span class="file" title="'+ CommonTempFileVoList[i].fileName +'">' + CommonTempFileVoList[i].fileName + ' </span>'
                    +'  <span class="filesize">/ '+ getManagedFileSize(CommonTempFileVoList[i].fileSize) +'</span>'
                    +' </a>'
                    +' <a href="#none" onclick="bizMsgTempFileDelete(\'tempFileId' + countTempFileId + '\', \'' + CommonTempFileVoList[i].tempName + '\', ' + CommonTempFileVoList[i].fileSize + ');">'
                    +'  <b>X</b>'
                    +' </a>'
                    +'</li>'
                );
            }
            if(paramDivision == 3){
                document.getElementById('fax_total_data').innerHTML = getManagedFileSize(totalFileSize);
            }
        }
        /*******************************************************************************************
         * 파일업로드 - 임시 첨부파일 (REG) 삭제
         *******************************************************************************************/
        function bizMsgTempFileDelete(tempFileId, tempName, fileSize)
        {
            totalFileSize -= fileSize;
            jQuery('#' + tempFileId).remove();
            commonUploadDwr.deleteTempFile(tempName, function(){});
            if(document.getElementById('add_file'+paramDivision).getElementsByTagName('li').length == 0){
                var tags = new Array();
                tags.push('<li id="empty_file'+paramDivision+'">첨부파일이 없습니다.</li>');
                jQuery('#ad