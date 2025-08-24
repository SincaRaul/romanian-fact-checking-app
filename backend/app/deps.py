from fastapi import Header
from typing import Optional

async def device_id_header(x_device_id: Optional[str] = Header(default=None)) -> Optional[str]:
    # MVP: putem folosi acest header pentru a preveni voturi multiple
    return x_device_id
