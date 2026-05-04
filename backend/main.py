from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional
from fastapi.middleware.cors import CORSMiddleware
import random
import uvicorn
import logging

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Gravity AI Backend")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class ScanRequest(BaseModel):
    lat: float
    lon: float
    sector: Optional[str] = None

class PolygonPoint(BaseModel):
    lat: float
    lon: float

class ScanResponse(BaseModel):
    increased_area_pct: int
    area_sqm: int
    land_value: float
    green_loss: int
    penalty: float
    pmay_families: int
    legal_notice_text: str
    anomaly_polygon: List[PolygonPoint]
    govt_boundary: List[PolygonPoint]
    status: str

@app.get("/")
async def root():
    return {"message": "Gravity AI Backend is running"}

import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

@app.post("/api/send_email")
async def send_email(request: dict):
    logger.info(f"Received email transmission request: {request}")
    receiver = request.get("receiver", "kunalsahu81202@gmail.com") # User can change this receiver
    details = request.get("details", "")
    
    # ⚠️ TODO: Replace with your actual Gmail and 16-digit App Password
    sender_email = "kunalsahu812026@gmail.com" 
    app_password = "KUNALSAHU@123456" 
    
    print("="*50)
    print("🚀 [GRAVITY SMTP] AUTOMATED EMAIL DISPATCHER")
    print(f"To: {receiver}")
    print(f"From: {sender_email}")
    print(f"Subject: URGENT: Gravity AI - Official Notice/Report")
    print(f"Body:\n{details}")
    print("="*50)
    
    if sender_email == "your_email@gmail.com":
        return {"status": "success", "message": f"Simulated! Put real Gmail & App Password in main.py to send actual emails."}
        
    try:
        msg = MIMEMultipart()
        msg['From'] = sender_email
        msg['To'] = receiver
        msg['Subject'] = "URGENT: Gravity AI - Official Notice/Report"
        msg.attach(MIMEText(details, 'plain'))
        
        server = smtplib.SMTP('smtp.gmail.com', 587)
        server.starttls()
        server.login(sender_email, app_password)
        server.send_message(msg)
        server.quit()
        return {"status": "success", "message": f"Email transmitted securely to {receiver}"}
    except Exception as e:
        logger.error(f"Failed to send email: {e}")
        return {"status": "error", "message": str(e)}


@app.post("/api/scan", response_model=ScanResponse)
async def trigger_scan(request: ScanRequest):
    logger.info(f"Received scan request: {request}")
    try:
        # Simulate geospatial analysis processing time
        # In a real scenario, this would call a ML model or Bhuvan API
        
        # Generate random but realistic metrics
        increased_area_pct = random.randint(15, 85)
        area_sqm = random.randint(50, 5000)
        land_value = round(random.uniform(100000.0, 5000000.0), 2)
        green_loss = random.randint(5, 40)
        penalty = round(land_value * 0.15, 2)  # Mock penalty based on land value
        pmay_families = random.randint(2, 15)
        legal_notice_text = f"UNAUTHORIZED CONSTRUCTION DETECTED.\n\nSector: {request.sector}\nCoordinates: {request.lat}, {request.lon}\n\nYou are hereby directed to halt all construction activities and clear the encroached area of {area_sqm} sq.m within 15 days, failing which demolition will be initiated under Section 248 of MPLRC, 1959. Penalty of Rs. {penalty} levied."
        
        # Generate a mock anomaly polygon (a square around the input coordinates)
        # 0.0005 is roughly 50 meters
        offset = 0.0005 
        anomaly_polygon = [
            PolygonPoint(lat=request.lat + offset, lon=request.lon + offset),
            PolygonPoint(lat=request.lat + offset, lon=request.lon - offset),
            PolygonPoint(lat=request.lat - offset, lon=request.lon - offset),
            PolygonPoint(lat=request.lat - offset, lon=request.lon + offset),
        ]
        
        # Generate a mock govt boundary (slightly larger than anomaly)
        gov_offset = 0.001
        govt_boundary = [
            PolygonPoint(lat=request.lat + gov_offset, lon=request.lon + gov_offset),
            PolygonPoint(lat=request.lat + gov_offset, lon=request.lon - gov_offset),
            PolygonPoint(lat=request.lat - gov_offset, lon=request.lon - gov_offset),
            PolygonPoint(lat=request.lat - gov_offset, lon=request.lon + gov_offset),
        ]
        
        return ScanResponse(
            increased_area_pct=increased_area_pct,
            area_sqm=area_sqm,
            land_value=land_value,
            green_loss=green_loss,
            penalty=penalty,
            pmay_families=pmay_families,
            legal_notice_text=legal_notice_text,
            anomaly_polygon=anomaly_polygon,
            govt_boundary=govt_boundary,
            status="success"
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=5000)
