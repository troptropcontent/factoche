package shared_entity

type Address struct {
	Street  string `validate:"required"`
	City    string `validate:"required"`
	Zipcode string `validate:"required"`
}
