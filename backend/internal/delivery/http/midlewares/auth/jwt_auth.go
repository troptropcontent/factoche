package auth_midlewares

import (
	"net/http"
	"slices"
	"strings"

	"github.com/labstack/echo/v4"
	"github.com/troptropcontent/factoche/pkg/jwt"
)

type JWTConfig struct {
	JWTService   jwt.JWT
	PublicRoutes []string
}

func JWTAuth(config JWTConfig) echo.MiddlewareFunc {
	return func(next echo.HandlerFunc) echo.HandlerFunc {
		return func(c echo.Context) error {
			method := c.Request().Method
			path := c.Path() // Gets the route pattern like "/auth/profiles/:id"

			// Check if the route is public
			if slices.Contains(config.PublicRoutes, method+":"+path) {
				return next(c)
			}

			// Get authorization header
			authHeader := c.Request().Header.Get("Authorization")
			if authHeader == "" {
				return echo.NewHTTPError(http.StatusBadRequest, "missing authorization header")
			}

			// Check if the header starts with "Bearer "
			if !strings.HasPrefix(authHeader, "Bearer ") {
				return echo.NewHTTPError(http.StatusBadRequest, "invalid authorization header format")
			}

			// Extract the token
			token := strings.TrimPrefix(authHeader, "Bearer ")

			// Verify the token
			claims, err := config.JWTService.VerifyToken(token)
			if err != nil {
				return echo.NewHTTPError(http.StatusUnauthorized, "invalid token")
			}

			// Set claims in context for later use
			c.Set("user_id", claims.UserID)
			c.Set("email", claims.Email)

			return next(c)
		}
	}
}
