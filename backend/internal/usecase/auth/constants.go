package auth_usecase

import "time"

const ACCESS_TOKEN_DURATION = time.Hour * 24
const REFRESH_TOKEN_DURATION = time.Hour * 24 * 30
