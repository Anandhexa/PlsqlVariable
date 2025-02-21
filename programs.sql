CREATE OR REPLACE PROCEDURE GetEmployeeInfo (
    p_employee_id IN employees.employee_id%TYPE
) AS
    v_exists BOOLEAN;
    v_salary employees.salary%TYPE;
    v_employee_name employees.employee_name%TYPE;
    v_department employees.department%TYPE;
    v_job_title employees.job_title%TYPE;
    v_hire_date employees.hire_date%TYPE;
    v_annual_bonus NUMBER;
    v_performance_bonus NUMBER;
    v_total_compensation NUMBER;
    v_monthly_salary NUMBER;
    v_years_with_company NUMBER;
    v_performance_rating NUMBER;
    v_response_text VARCHAR2(32767);
    v_http_request  UTL_HTTP.req;
    v_http_response UTL_HTTP.resp;
    v_url           VARCHAR2(2000);
BEGIN
    -- Check if the employee exists
    SELECT COUNT(*)
    INTO v_exists
    FROM employees
    WHERE employee_id = p_employee_id;

    -- If the employee exists, retrieve their details
    IF v_exists THEN
        SELECT salary, employee_name, department, job_title, hire_date
        INTO v_salary, v_employee_name, v_department, v_job_title, v_hire_date
        FROM employees
        WHERE employee_id = p_employee_id;

        -- Calculation Node 1: Calculate annual bonus as 10% of salary
        v_annual_bonus := v_salary * 0.10;

        -- Calculation Node 2: Calculate performance bonus as 15% of salary
        v_performance_bonus := v_salary * 0.15;

        -- Calculation Node 3: Calculate total compensation
        v_total_compensation := v_salary + v_annual_bonus + v_performance_bonus;

        -- Calculation Node 4: Calculate monthly salary
        v_monthly_salary := v_salary / 12;

        -- Calculation Node 5: Calculate years with the company
        v_years_with_company := EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM v_hire_date);

        -- Service Call: Make an HTTP request to get the employee's performance rating
        v_url := 'http://example.com/api/getPerformanceRating?employeeId=';
        v_http_request := UTL_HTTP.begin_request(v_url);
        v_http_response := UTL_HTTP.get_response(v_http_request);

        BEGIN
            LOOP
                UTL_HTTP.read_text(v_http_response, v_response_text);
            END LOOP;
        EXCEPTION
            WHEN UTL_HTTP.end_of_body THEN
                UTL_HTTP.end_response(v_http_response);
        END;

        -- Output the employee details and calculations
        DBMS_OUTPUT.PUT_LINE('Employee Name: ' || v_employee_name);
        DBMS_OUTPUT.PUT_LINE('Salary: ' || v_salary);
    ELSE
        -- If the employee does not exist, output a message
        DBMS_OUTPUT.PUT_LINE('Employee not found.');
    END IF;
END GetEmployeeInfo;
