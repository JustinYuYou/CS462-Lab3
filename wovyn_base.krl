ruleset wovyn_base {
   meta {
      use module twilio
         with
            sid = meta:rulesetConfig{"sid"}
            authToken = meta:rulesetConfig{"authToken"}
            fromNumber = "+18305803542"
            toNumber = "+13853849981"
      shares message
   }

   global {
      temperature_threshold = 20
      message = function() {
         twilio:message()
      }
   }

   rule process_heartbeat {
      select when wovyn heartbeat where event:attrs{"genericThing"} 
      send_directive("heartbeat", {"body": "Beat beat"})

      fired {
         raise wovyn event "new_temperature_reading"
            attributes {
               "temperature": event:attrs{"genericThing"}{"data"}{"temperature"}[0]{"temperatureF"},
               "timestamp": event:time
            } 
      }
   }

   rule find_high_temps {
      select when wovyn new_temperature_reading
      always {
         raise wovyn event "threshold_violation"
            attributes event:attrs
            if event:attrs >< "temperature" && event:attrs{"temperature"} > temperature_threshold
      }
   }

   rule threshold_notification {
      select when wovyn threshold_violation
      twilio:sendMessage()
   }
}