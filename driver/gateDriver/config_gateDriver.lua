return{
  CORE_CONFIG_PATH = "/config/config", -- standard PATH "/config/config", only alter when not running on alarmSysOS
  PROTOCOL = "control", -- standard for actors and sensor is "control"
  
--Feedback config
  
  FEEDBACK_ACTIVE_ON = true, 
  FEEDBACK_INACTIVE_ON = true,
  FEEDBACK_SIDE_ACTIVE = "right", 
  FEEDBACK_SIDE_INACTIVE = "left",

--Status Strings
  
  FEEDBACK_RETURN_STRING_ACTIVE = "active",
  FEEDBACK_RETURN_STRING_INACTIVE = "inactive",
  FEEDBACK_RETURN_STRING_NEITHER = "moving",
  FEEDBACK_RETURN_STRING_ELSE = "error",

  --Action config

  ACTIVATE_REDSTONE_SIDE = "", -- if empty -> no side used
  PULSE_REDSTONE_SIDE = "back", 
  PULSE_TIME = 1
}
