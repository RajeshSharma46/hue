
import io
import sys
import traceback
from pyrogram import Client, filters
from pyrogram.types import Message
from megadl.helpers_nexa.decorators import is_public
import asyncio
from io import BytesIO

MAX_MESSAGE_LENGTH = 4000


@Client.on_message(filters.command("peval") & filters.private)
@is_public
async def eval(client, message):
    status_message = await message.reply_text("Processing ...")
    cmd = message.text.split(" ", maxsplit=1)[1]

    reply_to_ = message
    if message.reply_to_message:
        reply_to_ = message.reply_to_message

    old_stderr = sys.stderr
    old_stdout = sys.stdout
    redirected_output = sys.stdout = io.StringIO()
    redirected_error = sys.stderr = io.StringIO()
    stdout, stderr, exc = None, None, None

    try:
        await aexec(cmd, client, message)
    except Exception:
        exc = traceback.format_exc()

    stdout = redirected_output.getvalue()
    stderr = redirected_error.getvalue()
    sys.stdout = old_stdout
    sys.stderr = old_stderr

    evaluation = ""
    if exc:
        evaluation = exc
    elif stderr:
        evaluation = stderr
    elif stdout:
        evaluation = stdout
    else:
        evaluation = "Success"

    final_output = "<b>EVAL</b>: "
    final_output += f"<code>{cmd}</code>\n\n"
    final_output += "<b>OUTPUT</b>:\n"
    final_output += f"<code>{evaluation.strip()}</code> \n"

    if len(final_output) > MAX_MESSAGE_LENGTH:
        with io.BytesIO(str.encode(final_output)) as out_file:
            out_file.name = "eval.text"
            await reply_to_.reply_document(
                document=out_file,
                caption=cmd[: MAX_MESSAGE_LENGTH // 4 - 1],
                disable_notification=True,
                quote=True,
            )
    else:
        await reply_to_.reply_text(final_output, quote=True)
    await status_message.delete()


async def aexec(code, client, message):
    exec(
        "async def __aexec(client, message): "
        + "".join(f"\n {l_}" for l_ in code.split("\n"))
    )
    return await locals()["__aexec"](client, message)



@Client.on_message(filters.command("psh") & filters.private)
@is_public
async def execution(_, message):
    status_message = await message.reply_text("Processing ...")
    # DELAY_BETWEEN_EDITS = 0.3
    # PROCESS_RUN_TIME = 100
    cmd = message.text.split(" ", maxsplit=1)[1]

    reply_to_ = message
    if message.reply_to_message:
        reply_to_ = message.reply_to_message

    # start_time = time.time() + PROCESS_RUN_TIME
    process = await asyncio.create_subprocess_shell(
        cmd, stdout=asyncio.subprocess.PIPE, stderr=asyncio.subprocess.PIPE
    )
    stdout, stderr = await process.communicate()
    e = stderr.decode()
    if not e:
        e = "😂"
    o = stdout.decode()
    if not o:
        o = "😐"

    OUTPUT = ""
    OUTPUT += f"<b>QUERY:</b>\n<u>Command:</u>\n<code>{cmd}</code> \n"
    OUTPUT += f"<u>PID</u>: <code>{process.pid}</code>\n\n"
    OUTPUT += f"<b>stderr</b>: \n<code>{e}</code>\n\n"
    OUTPUT += f"<b>stdout</b>: \n<code>{o}</code>"

    if len(OUTPUT) > MAX_MESSAGE_LENGTH:
        with BytesIO(str.encode(OUTPUT)) as out_file:
            out_file.name = "exec.text"
            await reply_to_.reply_document(
                document=out_file,
                caption=cmd[: MAX_MESSAGE_LENGTH // 4 - 1],
                disable_notification=True,
                quote=True,
            )
    else:
        await reply_to_.reply_text(OUTPUT, quote=True)

    await status_message.delete()
