import discord
from discord.ext import commands
import boto3
import requests
import sys
from io import BytesIO
from PIL import Image

rekog_client = boto3.client("rekognition")
ssm_client = boto3.client("ssm")

intents = discord.Intents.default()
intents.message_content = True
intents.guild_messages = True

DISALLOWED_IMAGES_CATEGORY = ["Smoking", "Explicit", "Violence", "Gambling"]

class MessageHandler(discord.Client):
    
    async def on_message(self, message):
        if message.author.id == self.user.id:
            return
        if message.attachments:
            for attachment in message.attachments:
                image_url = attachment.url
                image_data = requests.get(url=image_url).content
                image_data_size = sys.getsizeof(image_data)/1024/1024
                if image_data_size > 5.0:
                    print(f"Image size is {round(image_data_size,2)} MB which is greater than 5 MB. Resizing....")
                    img_bytesIO = Image.open(BytesIO(image_data))
                    img_bytesIO.thumbnail((img_bytesIO.width // (5.0 / image_data_size), img_bytesIO.height // (5.0 / image_data_size)), Image.ANTIALIAS)
                    output = BytesIO()
                    img_bytesIO.save(output, format=img_bytesIO.format)
                    image_data = output.getvalue()
                    new_image_data_size = sys.getsizeof(image_data)/1024/1024
                    print(f"Image size after resize: {round(new_image_data_size,2)} MB")
                    output.seek(0)
                responce = rekog_client.detect_moderation_labels(Image={
                    "Bytes": image_data
                })
                print(responce)

                if responce["ModerationLabels"]:
                    foundDisallowedContent = False
                    disallowedContent = ""
                    for finding in responce["ModerationLabels"]:
                        if finding["Name"] in DISALLOWED_IMAGES_CATEGORY:
                            foundDisallowedContent = True
                            disallowedContent = finding["Name"]
                            break
                    if foundDisallowedContent:
                        await message.reply(f"{message.author.mention}, Your image was removed as posting {disallowedContent} content is disallowed in this channel", mention_author = True)
                        await message.delete()
                        break
                        


client = MessageHandler(intents=intents)

botToken = ssm_client.get_parameter(Name="/discord/bot/secret-token")["Parameter"]["Value"]


client.run(botToken)