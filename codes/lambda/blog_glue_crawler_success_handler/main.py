import logging
import boto3
import os
import json
from datetime import datetime

data_set_map = {}
data_set_map[os.environ['APP_GLUE_CRAWLER_NAME']
             ] = os.environ['APP_QS_DATA_SET_IDS'].split(',')

quicksight = boto3.client('quicksight')

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)


def lambda_handler(event, context):
    account_id = event["account"]
    succeededJob = event['detail']['crawlerName']
    data_set_ids = []
    if succeededJob in data_set_map:
        data_set_ids = data_set_map[succeededJob]
        result = create_ingestion(account_id, data_set_ids)
        if result:
            logger.info('AWS Glue Job {} succeeded, ingestion created for associated QuickSight datasets {}.'.format(
                succeededJob, data_set_ids))
        else:
            logger.error('AWS Glue Job {} succeeded, failed to create ingestions for datasets {}.'.format(
                succeededJob, data_set_ids))
    else:
        logger.error(
            'AWS Glue Job {} succeeded, no associated QuickSight datasets found.'.format(succeededJob))
    
def create_ingestion(account_id, data_set_ids):
    logger.info('Creating the SPICE ingestions')

    for data_set_id in data_set_ids:
        dt_string = datetime.now().strftime("%Y%m%d-%H%M%S")
        ingestion_id = dt_string + '-' + data_set_id

        try:
            response = quicksight.create_ingestion(AwsAccountId=account_id, DataSetId=data_set_id,
                                                   IngestionId=ingestion_id)

            logger.info('Created ingestion for dataset {} with an ingestion id of {}.'.format(
                data_set_id, ingestion_id))

        except quicksight.exceptions.ResourceNotFoundException as rnfe:
            logger.error(
                'Dataset with id {} not found. {}'.format(data_set_id, rnfe))
            return False

    return True