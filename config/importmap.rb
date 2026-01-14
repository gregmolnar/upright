# Pin engine JavaScript
pin "upright/application", to: "upright/application.js"
pin "upright/controllers/application", to: "upright/controllers/application.js"
pin "upright/controllers", to: "upright/controllers/index.js"

pin_all_from Upright::Engine.root.join("app/javascript/upright/controllers"),
             under: "upright/controllers",
             to: "upright/controllers"
