# counter.rb
#
# English resource file for access counter plugin.
#
# Copyright (c) 2006 Masao Mutoh
# You can redistribute it and/or modify it under GPL2 or any later version.
#

@counter_conf_counter ||= "Access counter"
@counter_conf_init_head ||= "Initial number"
@counter_conf_init_desc ||= "Set initial number. Default value is 0."
@counter_conf_init_label ||= "Initial value:"
@counter_conf_log_head ||= "Logging"
@counter_conf_log_desc ||= "Save the access number logs for each days.<br/>The log is saved to &quot;#{@cache_path}/counter/counter.log&quot;."
@counter_conf_log_true ||= "Enable"
@counter_conf_log_false ||= "Disable"
@counter_conf_timer_head ||= "Visitor's interval(cookie)"
@counter_conf_timer_desc ||= "Don't count a visitor who repeat to access this tDiary for this interval using cookie. Default value is 12(hour)."
@counter_conf_timer_label ||= "Visitor's interval:"
@counter_conf_timer_unit ||= "hour"
@counter_conf_deny_same_src_interval_head ||= "Visitor's interval(without cookie)"
@counter_conf_deny_same_src_interval_desc ||= "Don't count a visitor who isn't enable the cookie for this interval. This function aims to deny to access repeatly from the same user agent without cookie. Default value is 4 hour."
@counter_conf_deny_same_src_interval_label ||= "Visitor's interval:"
@counter_conf_deny_same_src_interval_unit ||= "hour"
@counter_conf_max_keep_access_num_head ||= "Max number to keep the visitors"
@counter_conf_max_keep_access_num_desc ||= "Max number to keep the visitors for &quot;Visitor's interval(without cookie)&quot;. Default value is 10000."
@counter_conf_max_keep_access_num_label ||= "Max number to keep the visitors"
@counter_conf_max_keep_access_num_unit ||= "visitors"
@counter_conf_deny_user_agents_head ||= "Deny user agents against spams"
@counter_conf_deny_user_agents_desc ||= "Don't count a visitor which user agents are defined here. Usually, Crawler/Robots are set. You can use regexp. <pre>(e.g.) Googlebot|Bulkfeeds</pre>
<p>Entried user agents are below:"
@counter_conf_deny_user_agents_label ||= "Deny user agents: "
@counter_conf_kiriban_head ||= "Kiriban(memorial number)"
@counter_conf_kiriban_desc ||= "Kiriban is the memorial number. (e.g.) 100,123,300"
@counter_conf_kiriban_label_all ||= "Kiribans:"
@counter_conf_kiriban_label_today ||= "Today's Kiribans:"
@counter_conf_kiriban_messages_head ||= "The messages on the 'kiriban'"
@counter_conf_kiriban_messages_desc ||= "Describe &lt;%= kiriban %&gt; in the header or footer, this messages will be shown when the counter number reaches to the Kiriban."
@counter_conf_kiriban_messages_label_all ||= "Kiriban message:"
@counter_conf_kiriban_messages_label_today ||= "Today's Kiriban message:"
@counter_conf_kiriban_messages_label_nomatch ||= "Default(Not Kiriban)message:"

# Local Variables:
# mode: ruby
# indent-tabs-mode: t
# tab-width: 3
# ruby-indent-level: 3
# End:
