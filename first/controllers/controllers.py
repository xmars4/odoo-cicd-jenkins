# -*- coding: utf-8 -*-
# from odoo import http


# class First(http.Controller):
#     @http.route('/first/first', auth='public')
#     def index(self, **kw):
#         return "Hello, world"

#     @http.route('/first/first/objects', auth='public')
#     def list(self, **kw):
#         return http.request.render('first.listing', {
#             'root': '/first/first',
#             'objects': http.request.env['first.first'].search([]),
#         })

#     @http.route('/first/first/objects/<model("first.first"):obj>', auth='public')
#     def object(self, obj, **kw):
#         return http.request.render('first.object', {
#             'object': obj
#         })
