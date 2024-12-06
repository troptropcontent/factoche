package auth_handler

import (
	"net/http"

	"github.com/labstack/echo/v4"
	auth_usecase "github.com/troptropcontent/factoche/internal/usecase/auth"
)

type RefreshHandler interface {
	Handle(c echo.Context) error
}

type refreshHandler struct {
	refreshUseCase auth_usecase.RefreshUseCase
}

func NewRefreshHandler(ruc auth_usecase.RefreshUseCase) RefreshHandler {
	return &refreshHandler{
		refreshUseCase: ruc,
	}
}

type refreshRequest struct {
	RefreshToken string `json:"refresh_token"`
}

type refreshResponse struct {
	AccessToken string `json:"access_token"`
}

func (rh *refreshHandler) Handle(c echo.Context) error {
	req := refreshRequest{}

	if err := c.Bind(&req); err != nil {
		return echo.NewHTTPError(http.StatusBadRequest, "invalid request format")
	}

	accessToken, err := rh.refreshUseCase.Execute(c.Request().Context(), req.RefreshToken)
	if err != nil {
		return echo.NewHTTPError(http.StatusUnauthorized, "invalid credentials")
	}

	resp := refreshResponse{
		AccessToken: accessToken,
	}

	return c.JSON(http.StatusOK, resp)
}
