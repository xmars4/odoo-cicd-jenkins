{
    'name': 'Website Title',
    'version': '16.0.1.0.0',
    'category': 'Services',
    'summary': """""",
    'description': """""",
    'author': 'Sota Solutions',
    'company': 'Sota Solutions',
    'maintainer': 'Sota Solutions',
    'website': "https://demo.erp.sota-solutions.com/",
    'depends': ['web'],
    'assets': {
        'web.assets_backend': [
            ('after', 'web/static/src/webclient/webclient.js', 'sota_website_title/static/src/webclient/webclient.js'),
        ],
    },
    'data': [
        'views/res_company_views.xml'
    ],
    'license': 'LGPL-3',
}
