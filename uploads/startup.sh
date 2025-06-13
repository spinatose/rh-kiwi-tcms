/venv/bin/python /Kiwi/manage.py set_domain kiwi-tcms-bca4a5bnddhuakeq.eastus-01.azurewebsites.net
/venv/bin/python /Kiwi/manage.py collectstatic --noinput


# sh -c "/Kiwi/uploads/startup.sh"  -- this is the startup script to set domain and call collectstatic