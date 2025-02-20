-- PL/SQL
CREATE OR REPLACE PROCEDURE manage_employee_data (
  p_employee_id IN NUMBER
) AS
  -- Declare variables
  v_employee_name VARCHAR2(100);
  v_current_salary NUMBER;
  v_new_salary NUMBER;
BEGIN
  -- Fetch employee details
  SELECT employee_name, salary INTO v_employee_name, v_current_salary
  FROM employees
  WHERE employee_id = p_employee_id;

  -- Calculate new salary (e.g., a 10% raise)
  v_new_salary := v_current_salary * 1.10;

  -- Update salary in the database
  UPDATE employees
  SET salary = v_new_salary
  WHERE employee_id = p_employee_id;

  -- Log the change
  INSERT INTO salary_log (employee_id, old_salary, new_salary, change_date)
  VALUES (p_employee_id, v_current_salary, v_new_salary, SYSDATE);

END manage_employee_data;
/
