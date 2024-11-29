package env

import (
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
)

func Test_env_MustGet(t *testing.T) {
	type fields struct {
		prefix string
	}
	type args struct {
		key string
	}
	tests := []struct {
		name        string
		fields      fields
		args        args
		want        string
		shouldPanic bool
		before      func()
		after       func()
	}{
		{
			name: "When the environment variable is set it should return the value",
			fields: fields{
				prefix: "TOTO",
			},
			args: args{key: "TITI"},
			want: "test",
			before: func() {
				os.Setenv("TOTO_TITI", "test")
			},
			after: func() {
				os.Unsetenv("TOTO_TITI")
			},
			shouldPanic: false,
		},
		{
			name: "When the environment variable is not set it should panic",
			fields: fields{
				prefix: "TOTO",
			},
			args:        args{key: "TITI"},
			want:        "",
			shouldPanic: true,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			e := NewEnv(tt.fields.prefix)
			if tt.before != nil {
				tt.before()
			}
			defer func() {
				if tt.after != nil {
					tt.after()
				}
			}()
			if tt.shouldPanic {
				assert.Panics(t, func() {
					e.MustGet(tt.args.key)
				})
			} else {
				assert.Equal(t, tt.want, e.MustGet(tt.args.key))
			}
		})
	}
}

func Test_env_Get(t *testing.T) {
	type fields struct {
		prefix string
	}
	type args struct {
		key string
	}
	tests := []struct {
		name   string
		fields fields
		args   args
		want   string
		before func()
		after  func()
	}{
		{
			name: "When the environment variable is set it should return the value",
			fields: fields{
				prefix: "TOTO",
			},
			args: args{key: "TITI"},
			want: "test",
			before: func() {
				os.Setenv("TOTO_TITI", "test")
			},
			after: func() {
				os.Unsetenv("TOTO_TITI")
			},
		},
		{
			name: "When the environment variable is not set it should return an empty string",
			fields: fields{
				prefix: "TOTO",
			},
			args: args{key: "TITI"},
			want: "",
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			e := NewEnv(tt.fields.prefix)
			if tt.before != nil {
				tt.before()
			}
			defer func() {
				if tt.after != nil {
					tt.after()
				}
			}()
			assert.Equal(t, tt.want, e.Get(tt.args.key))
		})
	}

}

func Test_env_NewEnv(t *testing.T) {
	assert.NotNil(t, NewEnv("TOTO"))
}
