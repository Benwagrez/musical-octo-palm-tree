import time
import boto3
import json
import csv
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.application import MIMEApplication
from ipwhois import IPWhois

query = 'SELECT distinct client_ip, count() as count from alb_logs WHERE (parse_datetime(time,\'yyyy-MM-dd\'\'T\'\'HH:mm:ss.SSSSSS\'\'Z\') >= date_add(\'day\', -1, current_timestamp)) GROUP by client_ip ORDER by count() DESC;'
DATABASE = 'alb_db'
bucketname='octovmwebsitearm'
output='s3://'+bucketname+'/alb/QueryResults/'
email_subject = ''
email_body = ''

def lambda_handler(event, context):

    # Executing Athena Query
    query_success = query_visitors()
    
    time.sleep(1)
    # Executing Email
    if(query_success['ResponseMetadata']['HTTPStatusCode'] == 200):
        email_success = email_visitors(query_success['QueryExecutionId'])
    
    print(query_success)
    print(email_success)
    
    return {
        'statusCode': 200,
        'body': json.dumps("Email Sent Successfully. MessageId is: ")
    }
    

def query_visitors():
    client = boto3.client('athena')
    
    response = client.start_query_execution(
        QueryString=query,
        QueryExecutionContext={
            'Database': DATABASE
        },
        ResultConfiguration={
            'OutputLocation': output,
        }
    )
    print(response)
    return response
    
def email_visitors(QueryExecutionId):
    client = boto3.client('s3')
    response = client.get_object(Bucket=bucketname, Key="alb/QueryResults/"+QueryExecutionId+".csv")
    data = response['Body'].read().decode('utf-8').splitlines()
    lines = csv.reader(data)
    lines = list(lines)
    
    sender_ = 'benwagrez@gmail.com'
    recipients_ = ['benwagrez@gmail.com']
    title_ = "You had "+str(len(lines))+' Website Visitors'
    text_ = 'The text version\nwith multiple lines.'
    body_ = """<html><head><style>
    table {
      font-family: arial, sans-serif;
      border-collapse: collapse;
      width: 100%;
    }
    
    td, th {
      border: 1px solid #dddddd;
      text-align: left;
      padding: 8px;
    }
    
    tr:nth-child(even) {
      background-color: #dddddd;
    }
    </style>
    </head>
    <body>
    <h1>Viewer Insights</h1>
    <br>
    Here are the people that visited your website.
    <table>
      <tr>
        <th>IP</th>
        <th>Name</th>
        <th>Address</th>
        <th>Count</th>
      </tr>
    """
    attachments_ = []
    x = 0
    for line in lines:
        if (x == 1):
            obj = IPWhois(line[0])
            res = obj.lookup_rdap()
            if res is not None:
                if res['asn_description'] is not None:
                    body_ = body_+"<tr><td>"+line[0]+ "</td><td>"+res['asn_description']+"</td>"
                else:
                    body_ = body_+"<tr><td>"+line[0]+ "</td><td>N/A</td>"
                if res['objects'][res['entities'][0]]['contact']['address'] is not None:
                    body_ = body_+"<td>"+res['objects'][res['entities'][0]]['contact']['address'][0]['value']+ "</td><td>"+line[1]+ "</td></tr>"
                else:
                    body_ = body_+"<td>N/A</td><td>"+line[1]+ "</td></tr>"
            else:
                body_ = body_+"<tr><td>"+line[0]+ "</td><td>N/A</td><td>N/A</td><td>"+line[1]+ "</td></tr>"
        x = 1
    body_+="""
    </table>
    <br>
    This email was sent by the VisitorQuery Lambda function on AWS. If you want to unsubsribe, thats too bad I don't have that functionality. Throw a wrench at the cron job.
    """
    response_ = send_mail(sender_, recipients_, title_, text_, body_, attachments_)
    print(response_)
    return response_


def create_multipart_message(sender: str, recipients: list, title: str, text: str=None, html: str=None, attachments: list=None)\
        -> MIMEMultipart:
    """
    Creates a MIME multipart message object.
    Uses only the Python `email` standard library.
    Emails, both sender and recipients, can be just the email string or have the format 'The Name <the_email@host.com>'.

    :param sender: The sender.
    :param recipients: List of recipients. Needs to be a list, even if only one recipient.
    :param title: The title of the email.
    :param text: The text version of the email body (optional).
    :param html: The html version of the email body (optional).
    :param attachments: List of files to attach in the email.
    :return: A `MIMEMultipart` to be used to send the email.
    """
    multipart_content_subtype = 'alternative' if text and html else 'mixed'
    msg = MIMEMultipart(multipart_content_subtype)
    msg['Subject'] = title
    msg['From'] = sender
    msg['To'] = ', '.join(recipients)

    # Record the MIME types of both parts - text/plain and text/html.
    # According to RFC 2046, the last part of a multipart message, in this case the HTML message, is best and preferred.
    if text:
        part = MIMEText(text, 'plain')
        msg.attach(part)
    if html:
        part = MIMEText(html, 'html')
        msg.attach(part)

    # Add attachments
    for attachment in attachments or []:
        with open(attachment, 'rb') as f:
            part = MIMEApplication(f.read())
            part.add_header('Content-Disposition', 'attachment', filename=os.path.basename(attachment))
            msg.attach(part)

    return msg
    
def send_mail(sender: str, recipients: list, title: str, text: str=None, html: str=None, attachments: list=None) -> dict:
    """
    Send email to recipients. Sends one mail to all recipients.
    The sender needs to be a verified email in SES.
    """
    msg = create_multipart_message(sender, recipients, title, text, html, attachments)
    ses_client = boto3.client('ses')  # Use your settings here
    return ses_client.send_raw_email(
        Source=sender,
        Destinations=recipients,
        RawMessage={'Data': msg.as_string()}
    )
    
    