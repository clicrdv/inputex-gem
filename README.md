inputex-gem [![Build Status](https://travis-ci.org/clicrdv/inputex-gem.png)](https://travis-ci.org/clicrdv/inputex-gem) [![Gem Version](https://badge.fury.io/rb/inputex.png)](http://badge.fury.io/rb/inputex) [![Coverage Status](https://coveralls.io/repos/clicrdv/inputex-gem/badge.png)](https://coveralls.io/r/clicrdv/inputex-gem) ![Code Climate](https://codeclimate.com/github/clicrdv/inputex-gem.png)](https://codeclimate.com/github/clicrdv/inputex-gem)
=========== 

Interface the [inputex](https://github.com/neyric/inputex) UI library with ActiveRecord models to generate an [inputex](https://github.com/neyric/inputex) field definition.

__Warning: this gem is only compatiable with ActiveSupport <= 3, it will not work with ActiveSupport 4__


Helpers
=======

Helpers to generate inputEx forms from ActiveRecord models.


  * fields named ```id``` are hidden
  * ```created_at```, ```updated_at``` are uneditable
  * ```email```, ```url```, ```password```, ```colorref```, ```ip``` are rendered using the corresponding inputEx field
  * columns finishing by ```_id``` are rendered with their own type, corresponding to the REFLECTION CLASS, E.g: A class with a ```owner_id``` column, and this in the model:
```
          belongs_to :owner, :class_name => "Group"
```
__=> the generated type will be ```group_id``` (and not ```owner_id```)__

  * renders datetime, boolean, text, integers, ...
  * renders select according to the ActiveModel validations
```
      validates :format, :inclusion => { :in => ["json", "xml", "urlencoded"] }
```

Usage
=====

 * I18n MUST be configured.
   The gem will look for the key "activerecord.attributes.#{self.name.downcase}.#{column.name}"

 * Get all fields (The order is generally wrong)
```
   MyModel.inputex_fields_definition
```

 * Get the fields "id" and "method" (in the same order)
```
   MyModel.inputex_fields_definition(["id","method"])
```

 * Get a definition given a column
```
   MyModel.inputex_field_definition(column, force_uneditable = false)
```

 * Get a definition given a column name
```
   MyModel.inputex_field_byname(columnName, force_uneditable = false)
```

Copyright (c) 2010-2013 ClicRDV
