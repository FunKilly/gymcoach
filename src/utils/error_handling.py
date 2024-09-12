from fastapi import status
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse

from src.utils.exceptions import BaseException


async def handle_base_exception(request, exc: BaseException):
    data = {"message": exc.message, "field": exc.field}
    return JSONResponse(
        status_code=exc.status_code or status.HTTP_400_BAD_REQUEST,
        content={"errors": [data]},
    )


async def handle_request_validation_exception(
    request, exc: RequestValidationError
) -> JSONResponse:
    error_data = []
    for error in exc.errors():
        error_locations = [str(field) for field in error.pop("loc", "")]
        error_field = ".".join(error_locations)

        error_message = error.pop("msg", "").capitalize() or "Unknown validation error"
        complete_error_message = (
            f"{error_message}: {error_field}" if error_field else error_message
        )

        error_data.append({"message": complete_error_message, "field": error_field})

    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={"errors": error_data},
    )
