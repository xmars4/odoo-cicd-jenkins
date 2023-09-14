FROM odoo:16

# USE root user instead of odoo to handle logging easier
USER root

COPY ./entrypoint.sh /
COPY ./odoo.conf /etc/odoo/

COPY ./requirements.txt /etc/odoo/requirements.txt
RUN pip3 install -r /etc/odoo/requirements.txt

RUN mkdir -p /mnt/et-addons \
    && chown -R odoo /mnt/et-addons \
    && chown odoo /etc/odoo/odoo.conf

VOLUME ["/mnt/et-addons"]
