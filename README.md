# WebRest API (.NET 8 + Oracle Database + Swagger)

**WebRest** is a RESTful API built using C# and ASP.NET Core. It connects to an **Oracle XE database** and exposes CRUD endpoints for interacting with the current schema.

---

## 🔧 Features

- Built with ASP.NET Core (.NET 8)
- Connected to Oracle DB via Entity Framework Core
- Swagger UI enabled for testing endpoints
- Controllers for core tables like `Customer`, `Address`, `Order`, etc.

---

## 🚀 Run the API Locally

```bash
dotnet build
dotnet watch -lp https
