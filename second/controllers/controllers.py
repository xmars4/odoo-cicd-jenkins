# -*- coding: utf-8 -*-
# from odoo import http


# class Second(http.Controller):
#     @http.route('/second/second', auth='public')
#     def index(self, **kw):
#         return "Hello, world"

#     @http.route('/second/second/objects', auth='public')
#     def list(self, **kw):
#         return http.request.render('second.listing', {
#             'root': '/second/second',
#             'objects': http.request.env['second.second'].search([]),
#         })

#     @http.route('/second/second/objects/<model("second.second"):obj>', auth='public')
#     def object(self, obj, **kw):
#         return http.request.render('second.object', {
#             'object': obj
#         })
