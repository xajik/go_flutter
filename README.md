<h1 align="center">  💻 Go Note 📝 </h1>

# ⭐️ Flutter Web + Go BE + Postgres DB + NGINX + Docker 🚀
## ⬇️ Project features: 
* ➕ add notes; 
* ➖ delete notes;
* 🔗 preview notes with the same tags;
* 👀  markdown support (edit or preview screen split);

### Preview
| | |
---------------------| - |
![](/img_example/go_note_img.png) | ![](/img_example/go_note_img_1.png)

## Requirements:
* Docker
* Docker-compose

## Run
* run in root folder: `docker-compose up -d`
* visit `https://localhost`
## Nginx
* Used for routing and SSL
## Flutter web front-end
* [Flutter web](https://flutter.dev/web)
* Front-end does not support hot reload in Docker.
## Postgres DB 
* See `postgres/migrations` for DB structure
* About migration script [read here](https://github.com/karlkeefer/pngr)
* DB does not have a valume - data will erase when after docekr go down
## GO backend
* HTTP server: [echo](https://github.com/labstack/echo)
* Postgress access with: [sqlx](https://github.com/jmoiron/sqlx) 
### References
* Inspired by [pngr](https://github.com/karlkeefer/pngr)
