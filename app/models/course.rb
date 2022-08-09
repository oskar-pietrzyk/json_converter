class Course < ApplicationRecord
  mount_uploader :converter_json, ConverterJsonUploader
end
