// This file is auto-generated by ./bin/rails stimulus:manifest:update
// Run that command whenever you add a new controller or create them with
// ./bin/rails generate stimulus controllerName

import { application } from "./application"

import AccountController from "./account_controller.js"
application.register("account", AccountController)

import ColumnFilterController from "./column_filter_controller.js"
application.register("column-filter", ColumnFilterController)

import NavController from "./nav_controller.js"
application.register("nav", NavController)
