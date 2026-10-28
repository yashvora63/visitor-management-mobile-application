# REST API Documentation & Integration Guide

**Application**: Visitor Management Mobile Application  
**Client / Domain**: Real Estate Residential Projects (Sumadhura Group)  
**Backend Architecture**: Mock REST API (MockAPI.io)  
**Base URL**: `https://6ae09a04be3bc8fead978a7c.mockapi.io/api/v1/`

---

## 1. Overview & Architecture

The application communicates with a persistent mock REST API hosted on MockAPI.io. The network layer is built using **Dio 5.11** with custom interceptors for timeouts, error formatting, and request logging.

All visitor CRUD operations, QR verification queries, and status transition timestamps persist across application restarts.

```
┌─────────────────────────┐          HTTP Request (JSON)          ┌──────────────────────────┐
│      Flutter App        │ ────────────────────────────────────► │      Mock REST API       │
│  (DioClient & Repo)     │ ◄──────────────────────────────────── │  (MockAPI.io Endpoint)   │
└─────────────────────────┘          HTTP Response (JSON)         └──────────────────────────┘
```

---

## 2. API Endpoints Catalog

| Method | Endpoint | Description | Request Body | Response Code |
| :---: | :--- | :--- | :---: | :---: |
| `GET` | `/visitors` | Retrieve full list of all registered visitors | None | `200 OK` |
| `GET` | `/visitors/:id` | Retrieve single visitor profile by unique ID | None | `200 OK` / `404` |
| `POST` | `/visitors` | Register new visitor with initial `Registered` status | Visitor JSON | `201 Created` |
| `PUT` | `/visitors/:id` | Full update of existing visitor information | Visitor JSON | `200 OK` |
| `PATCH` | `/visitors/:id` | Partial update for check-in / check-out status | Status JSON | `200 OK` |
| `DELETE` | `/visitors/:id` | Permanently remove visitor record | None | `200 OK` / `204` |

---

## 3. Data Model Schema

### Visitor Object Definition

| Field | Data Type | Nullable | Required | Validation / Description |
| :--- | :---: | :---: | :---: | :--- |
| `id` | `String` | No | Yes | Unique identifier (e.g., `"VIS001"` or auto-increment integer) |
| `name` | `String` | No | Yes | Full name of the visitor (minimum 2 characters) |
| `mobile` | `String` | No | Yes | 10-digit numeric phone number |
| `email` | `String` | Yes | No | Email address; validated against RFC pattern if provided |
| `visitor_type`| `String` | No | Yes | Classification: `"Customer"`, `"Vendor"`, or `"Other"` |
| `project` | `String` | No | Yes | Associated project: `"Project A"`, `"Project B"`, or `"Project C"` |
| `purpose` | `String` | No | Yes | Purpose of visit (e.g., `"Site Visit"`, `"Meeting"`, `"Delivery"`) |
| `status` | `String` | No | Yes | Lifecycle status: `"Registered"`, `"Checked In"`, or `"Checked Out"` |
| `created_at` | `String` | No | Yes | ISO 8601 registration timestamp (e.g., `"2026-10-28T10:00:00+05:30"`) |
| `check_in_time`| `String` | Yes | No | ISO 8601 timestamp when visitor checked in |
| `check_out_time`| `String` | Yes | No | ISO 8601 timestamp when visitor checked out |

---

## 4. Sample Payloads

### 4.1 Retrieve All Visitors (`GET /visitors`)
**Response (`200 OK`)**:
```json
[
  {
    "id": "VIS001",
    "name": "Rahul Sharma",
    "mobile": "9876543210",
    "email": "rahul.sharma@example.com",
    "visitor_type": "Customer",
    "project": "Project A",
    "purpose": "Site Visit",
    "status": "Registered",
    "created_at": "2026-10-28T09:30:00+05:30",
    "check_in_time": null,
    "check_out_time": null
  },
  {
    "id": "VIS002",
    "name": "Priya Nair",
    "mobile": "9123456789",
    "email": "priya.nair@example.com",
    "visitor_type": "Vendor",
    "project": "Project B",
    "purpose": "Material Delivery",
    "status": "Checked In",
    "created_at": "2026-10-28T10:00:00+05:30",
    "check_in_time": "2026-10-28T10:15:00+05:30",
    "check_out_time": null
  }
]
```

---

### 4.2 Register New Visitor (`POST /visitors`)
**Request**:
```json
{
  "id": "VIS003",
  "name": "Karan Verma",
  "mobile": "9811223344",
  "email": "karan.verma@example.com",
  "visitor_type": "Customer",
  "project": "Project C",
  "purpose": "Property Inspection",
  "status": "Registered",
  "created_at": "2026-10-28T11:00:00+05:30",
  "check_in_time": null,
  "check_out_time": null
}
```

**Response (`201 Created`)**:
```json
{
  "id": "VIS003",
  "name": "Karan Verma",
  "mobile": "9811223344",
  "email": "karan.verma@example.com",
  "visitor_type": "Customer",
  "project": "Project C",
  "purpose": "Property Inspection",
  "status": "Registered",
  "created_at": "2026-10-28T11:00:00+05:30",
  "check_in_time": null,
  "check_out_time": null
}
```

---

### 4.3 Check-In Visitor (`PATCH /visitors/:id`)
**Request**:
```json
{
  "status": "Checked In",
  "check_in_time": "2026-10-28T11:15:00+05:30"
}
```

**Response (`200 OK`)**:
```json
{
  "id": "VIS003",
  "name": "Karan Verma",
  "mobile": "9811223344",
  "email": "karan.verma@example.com",
  "visitor_type": "Customer",
  "project": "Project C",
  "purpose": "Property Inspection",
  "status": "Checked In",
  "created_at": "2026-10-28T11:00:00+05:30",
  "check_in_time": "2026-10-28T11:15:00+05:30",
  "check_out_time": null
}
```

---

### 4.4 Check-Out Visitor (`PATCH /visitors/:id`)
**Request**:
```json
{
  "status": "Checked Out",
  "check_out_time": "2026-10-28T12:30:00+05:30"
}
```

**Response (`200 OK`)**:
```json
{
  "id": "VIS003",
  "name": "Karan Verma",
  "mobile": "9811223344",
  "email": "karan.verma@example.com",
  "visitor_type": "Customer",
  "project": "Project C",
  "purpose": "Property Inspection",
  "status": "Checked Out",
  "created_at": "2026-10-28T11:00:00+05:30",
  "check_in_time": "2026-10-28T11:15:00+05:30",
  "check_out_time": "2026-10-28T12:30:00+05:30"
}
```

---

### 4.5 Delete Visitor (`DELETE /visitors/:id`)
**Response (`200 OK`)**:
```json
{
  "id": "VIS003",
  "name": "Karan Verma"
}
```

---

## 5. cURL Verification Commands

Evaluators can verify the live MockAPI backend directly from a terminal:

```bash
# 1. Retrieve all visitors
curl -X GET "https://6ae09a04be3bc8fead978a7c.mockapi.io/api/v1/visitors"

# 2. Retrieve single visitor by ID
curl -X GET "https://6ae09a04be3bc8fead978a7c.mockapi.io/api/v1/visitors/1"

# 3. Create a visitor
curl -X POST "https://6ae09a04be3bc8fead978a7c.mockapi.io/api/v1/visitors" \
  -H "Content-Type: application/json" \
  -d '{
    "id": "VIS050",
    "name": "Anita Desai",
    "mobile": "9876500000",
    "email": "anita@example.com",
    "visitor_type": "Customer",
    "project": "Project A",
    "purpose": "Site Inspection",
    "status": "Registered",
    "created_at": "2026-10-28T12:00:00+05:30",
    "check_in_time": null,
    "check_out_time": null
  }'

# 4. Check in the visitor
curl -X PATCH "https://6ae09a04be3bc8fead978a7c.mockapi.io/api/v1/visitors/VIS050" \
  -H "Content-Type: application/json" \
  -d '{"status":"Checked In","check_in_time":"2026-10-28T12:15:00+05:30"}'

# 5. Check out the visitor
curl -X PATCH "https://6ae09a04be3bc8fead978a7c.mockapi.io/api/v1/visitors/VIS050" \
  -H "Content-Type: application/json" \
  -d '{"status":"Checked Out","check_out_time":"2026-10-28T13:30:00+05:30"}'

# 6. Delete the visitor
curl -X DELETE "https://6ae09a04be3bc8fead978a7c.mockapi.io/api/v1/visitors/VIS050"
```

---

## 6. Error Handling & Resilience

The Dio client incorporates automatic error translation in [lib/utils/dio/dio_error_util.dart](file:///lib/utils/dio/dio_error_util.dart):

| HTTP Status / Exception | App Behavior | User Feedback |
| :--- | :--- | :--- |
| **`400 Bad Request`** | Prevents bad data dispatch; displays validation prompt | Toast / Dialog with error detail |
| **`404 Not Found`** | Caught during QR scan or visitor lookup | "Visitor not found for the scanned QR code" dialog |
| **`429 Too Many Requests`** | Handled gracefully with retry action button | "Server is busy. Please retry in a moment." |
| **`500 Internal Error`** | Catches backend failures | "Server error occurred. Please contact administrator." |
| **Connection Timeout** | Triggered after 30 seconds of inactivity | "Connection timed out. Please check network." |

