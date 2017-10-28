let fs = require('fs');
let fsSync = require('fs-sync');
let IpRegex = /^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/
let CommentChars = ['#']

let HostsName = 'hosts'
let BackName = 'hosts.bak'

let path = null
switch (process.platform) {
    case 'win32':
        path = 'c:\\Windows\\System32\\drivers\\etc\\'
        break;
    case 'linux':
        path = '/etc/'
        break;
    case 'darwin':
        path = '/private/etc/'
        break;
}

if (!path) {
    log(`Platform: ${process.platform} not supported`)
    return
}

let HostsPath = path + HostsName
let BakPath = path + BackName

let ArgStart = 2,
    ArgCount = 2,
    TotalCount = ArgStart + ArgCount

let argv = process.argv

if (argv.length < TotalCount) {
    log(`not enough parameters, give me a ip and a name`)
    return;
}

let ip = argv[ArgStart],
    name = argv[ArgStart + 1]


if (!isIp(ip)) {
    log(`Invalid ip: ${ip}`)
    return;
}



// create backup file
if (fs.existsSync(BakPath))
    fs.unlink(BakPath);

fsSync.copy(HostsPath, BakPath);

let lineReader = require('readline').createInterface({
    input: fs.createReadStream(BakPath)
})

let file = fs.createWriteStream(HostsPath)

let lineNo = 0;
let done = false;
lineReader.on('line', function processLine(line) {
    let entry = parseLine(line)
    if (!isValidEntry(entry)) {
        file.write(`${line}\n`);
        return;
    }

    let entryIp = entry[0]
    if (entryIp === ip) {
        if (entry.includes(name)) {
            log(`\t[${name}] for [${ip}] already exist!`)
            return
        }
        entry[0] = name
        let entryLine = normalizeEntry(entry);
        file.write(`${ip}\t${entryLine}\n`)
        done = true
        return
    } else if (entry.includes(name)) {
        for (let i = 0; i < entry.length; ++i) {
            if (entry[i] === name) {
                entry[i] = ''
            }
        }

        let entryLine = normalizeEntry(entry);
        file.write(`${entryLine}\n`)
        return
    }

    file.write(`${line}\n`);
})

lineReader.on('close', () => {
    if (!done) {
        file.write(`${ip}\t${name}\n`)
    }
})

// console.log(`This platform is ${process.platform}`);
// console.log(`Hello from version: ${process.version}`)


function isIp(str) {
    return IpRegex.test(str)
}

function log(content) {
    console.log(content)
}

function isValidEntry(array) {
    if (array.length >= 1 && isIp(array[0]))
        return true;
    return false;
}

function isComment(strLine) {
    var trimLine = strLine.trim()
    for (let i = 0; i < CommentChars.length; ++i) {
        if (trimLine.startsWith(CommentChars[i])) {
            return true;
        }
    }

    return false;
}

function parseLine(strLine) {
    if (!strLine)
        return []

    var line = strLine.trim()
    return line.split(/\s+/);
}

function normalizeEntry(arr) {
    return arr.join(' ')
}

// function test() {
//     let arr = parseLine('127.0.0.1 ');
//     let valid = isValidEntry(arr);
//     log(valid)
// }