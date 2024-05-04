import boto3
import datetime
#date_filter = (datetime.datetime.now() - datetime.timedelta(minutes=1)).strftime("%Y-%m-%d %H:%M:%S")
#Fetching year to filter running instances contaning year in thei Name # Line 16
year=datetime.datetime.today().year
region = 'ap-southeast-2'
ec2 = boto3.client('ec2', region_name=region)

def instances():
    running_instances = []
    print('Into DescribeEc2Instance')
    filter=[{'Name': 'instance-state-name', 'Values': ["running"]},
    {'Name': 'tag:Name', 'Values': ["*"+str(year)+"*"]}]
    instances = ec2.describe_instances(Filters=filter)
    for i in instances['Reservations']:
        for instance in i['Instances']:
            launch_time_str = instance['LaunchTime']
            if isinstance(launch_time_str, datetime.datetime):
                launch_time_str = launch_time_str.strftime("%Y-%m-%d %H:%M:%S")
            launch_time = datetime.datetime.strptime(launch_time_str, "%Y-%m-%d %H:%M:%S")
            if datetime.datetime.now() - launch_time > datetime.timedelta(minutes=10):
                running_instances.append(instance['InstanceId'])
            else:
                pass
    return running_instances

def delete_ec2():
    ec2_list = instances()
    if not ec2_list:
        return "No AMI creation instances running for more than 6 Hours"
    else:
        ec2.terminate_instances(
        InstanceIds=ec2_list,
        DryRun=False)
        return "terminated instance", ec2_list
def lambda_handler(event,context):
    return delete_ec2()
        
        
    
    
    
