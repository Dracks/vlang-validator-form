# Vlang ClassTransformer/Validator

Accepts any map[string]string and transforms into the struct you pass to it. 

Example:
```vlang
import validator

struct BasicObject {
    str string [req;min_length: 10; max_length: 30]
    number int [min: 5; max; 10]
}
...

data := validator.transform_and_validate[BasicObject]({
    "str": "Hello world!"
    "number": "42"
})
your_basic_object := data.value


if data.has_errors() {
    // you can get the errors from data.errors
    // where the key of the map is the field with error, 
    // internally you will have a list of errors
}
```

## Example of usage for a configuration
```vlang
import dracks.validator {transform_and_validate}

pub struct Config {
	debug           bool = true
	default_locale  string = 'en_US'
	login_demo_user bool
	port            int = 8081
}

pub fn load_config() !Config {
	env := os.environ()
	transform := transform_and_validate[Config](env)
	if transform.has_errors(){
		errors_str := transform.errors.keys().map(fn [transform] (field string) string {
			return '\t${field}: ${transform.errors[field]}\n'
		})

		return error('Invalid configuration\n${errors_str}')
	}
	return transform.value
}


pub fn (self Config) to_json() string {
	return json.encode(self)
}
```

## Notes
* SubStructs are not possible to work yet, for limitations of Vlang
* You cannot flag the attribute `required` from v, as the tool needs to create an empty object you can use req to force
* **floats not implemented yet**

## Accepted attributes
* `max_length`: validates the string has not more than the specified length
* `min_length`: validates the string has not less than the specified length
* `max`: Checks the number is not greather than specified
* `min`: checks the number is not lower than specified
* `req`: make the field required, it will fail if there is no default

## Valid types for the structure
* `bool`
* `int`
* `string`