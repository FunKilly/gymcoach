from fastapi import FastAPI
from fastapi.exceptions import RequestValidationError

from src.endpoints.routes import plans_router
from src.utils.error_handling import (handle_base_exception,
                                      handle_request_validation_exception)
from src.utils.exceptions import BaseException

app = FastAPI()
app.include_router(plans_router)

app.add_exception_handler(BaseException, handle_base_exception)
app.add_exception_handler(RequestValidationError, handle_request_validation_exception)
