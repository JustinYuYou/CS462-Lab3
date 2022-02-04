ruleset temperature_store {
   meta {
      provides temperatures, threshold_violations, inrange_temperatures
      shares temperatures, threshold_violations, inrange_temperatures
   }
   
   global {
      temperatures = function() {
         ent:temperatures
      }

      threshold_violations = function() {
         ent:temperaturesViolated
      }

      inrange_temperatures = function() {
         ent:temperatures.filter(function(temp){
            temperaturesViolated.index(temp) == -1
         })
      }
   }

   rule init {
      select when wrangler ruleset_added where rids >< meta:rid

      always {
         ent:temperatures := []
         ent:temperaturesViolated := []
      }
   }
   
   rule collect_temperatures {
      select when wovyn new_temperature_reading

      always {
         ent:temperatures := ent:temperatures.append({"temperature": event:attrs{"temperature"}, "timestamp": event:attrs{"temperature"}})
      }
   }

   rule collect_threshold_violations  {
      select when wovyn threshold_violation

      always {
         ent:temperaturesViolated := ent:temperaturesViolated.append({"temperature": event:attrs{"temperature"}, "timestamp": event:attrs{"temperature"}})
      }
   }

   rule clear_temperatures {
      select when sensor reading_reset

      always {
         clear ent:temperatures
         clear ent:temperaturesViolated
      }

   }
}