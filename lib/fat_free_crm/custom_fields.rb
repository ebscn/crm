# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# EverBright CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------

#
# Register CustomFields when Field class is loaded
ActiveSupport.on_load(:fat_free_crm_field) do # self == Field
  self.register(:as => 'date_pair', :klass => 'CustomFieldDatePair', :type => 'date')
  self.register(:as => 'datetime_pair', :klass => 'CustomFieldDatetimePair', :type => 'timestamp')
end