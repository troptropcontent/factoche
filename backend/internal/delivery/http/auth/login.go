package auth_handler

import (
	"net/http"

	"github.com/labstack/echo/v4"
	auth_usecase "github.com/troptropcontent/factoche/internal/usecase/auth"
)

type LoginHandler interface {
	Handle(c echo.Context) error
}

type loginHandler struct {
	loginUseCase auth_usecase.LoginUseCase
}

func NewLoginHandler(uc auth_usecase.LoginUseCase) LoginHandler {
	return &loginHandler{
		loginUseCase: uc,
	}
}

type LoginRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type LoginResponse struct {
	AccessToken  string `json:"accessToken"`
	RefreshToken string `json:"refreshToken"`
}

func (lh *loginHandler) Handle(c echo.Context) error {
	loginRequest := LoginRequest{}

	if err := c.Bind(&loginRequest); err != nil {
		return echo.NewHTTPError(http.StatusBadRequest, "Invalid request format")
	}

	accessToken, refreshToken, err := lh.loginUseCase.Execute(c.Request().Context(), loginRequest.Email, loginRequest.Password)
	if err != nil {
		return echo.NewHTTPError(http.StatusUnauthorized, "Invalid credentials")
	}

	loginResponse := LoginResponse{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
	}

	return c.JSON(http.StatusOK, loginResponse)
}
