import readline from 'readline';
import web3 from "@solana/web3.js";
import chalk from "chalk";
import bs58 from "bs58";

const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

rl.question('Enter your Solana wallet private key: ', (privkey) => {
    const connection = new web3.Connection("https://devnet.sonic.game", 'confirmed');
    const from = web3.Keypair.fromSecretKey(bs58.decode(privkey));
    const to = web3.Keypair.generate();

    const sendTransaction = async () => {
        const transaction = new web3.Transaction().add(
            web3.SystemProgram.transfer({
                fromPubkey: from.publicKey,
                toPubkey: to.publicKey,
                lamports: web3.LAMPORTS_PER_SOL * 0.001,
            })
        );
        const txCount = 20;
        let i = 0;
        const interval = setInterval(async () => {
            if (i < txCount) {
                const signature = await web3.sendAndConfirmTransaction(
                    connection,
                    transaction,
                    [from]
                );
                i++;
                console.log(chalk.blue('Tx hash :'), signature);
            } else {
                clearInterval(interval);
            }
        }, 90000);
        console.log("");
        const randomDelay = Math.floor(Math.random() * 3) + 1;
        await new Promise(resolve => setTimeout(resolve, randomDelay * 1000));
    };

    sendTransaction().then(() => rl.close()).catch((err) => {
        console.error(err);
        rl.close();
    });
});
