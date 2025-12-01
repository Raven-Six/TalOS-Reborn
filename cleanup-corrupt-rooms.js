import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import dotenv from 'dotenv';

// Get the directory name in ES modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load environment variables
const envPath = path.resolve(__dirname, '.env');
dotenv.config({ path: envPath });

// Determine the data path based on platform
const appDataDir = process.env.APPDATA ||
    (process.platform === 'darwin' ? process.env.HOME + '/Library/Preferences' :
        process.env.HOME + '/.local/share');

const talosDir = path.join(appDataDir, 'TalOS');
const dataPath = path.join(talosDir, 'data');
const roomsPath = path.join(dataPath, 'rooms');

console.log('Checking rooms directory:', roomsPath);

if (!fs.existsSync(roomsPath)) {
    console.log('Rooms directory does not exist.');
    process.exit(0);
}

const files = fs.readdirSync(roomsPath);
const jsonFiles = files.filter(file => file.endsWith('.json'));

console.log(`Found ${jsonFiles.length} JSON files in rooms directory`);

let corruptCount = 0;
let emptyCount = 0;
let validCount = 0;

jsonFiles.forEach(file => {
    const filePath = path.join(roomsPath, file);
    const stats = fs.statSync(filePath);
    
    console.log(`\nChecking: ${file} (${stats.size} bytes)`);
    
    try {
        const fileData = fs.readFileSync(filePath, 'utf-8');
        
        // Check if file is empty or only whitespace
        if (!fileData || fileData.trim() === '') {
            console.log(`  ⚠️  EMPTY FILE`);
            emptyCount++;
            
            // Optionally delete empty files
            const backupPath = filePath + '.backup';
            fs.copyFileSync(filePath, backupPath);
            console.log(`  📋 Backed up to: ${backupPath}`);
            
            fs.unlinkSync(filePath);
            console.log(`  🗑️  Deleted empty file`);
            return;
        }
        
        // Try to parse JSON
        const parsed = JSON.parse(fileData);
        console.log(`  ✅ Valid JSON`);
        validCount++;
        
    } catch (err) {
        console.log(`  ❌ CORRUPT FILE - ${err.message}`);
        corruptCount++;
        
        // Backup the corrupt file
        const backupPath = filePath + '.corrupt.backup';
        fs.copyFileSync(filePath, backupPath);
        console.log(`  📋 Backed up to: ${backupPath}`);
        
        // Delete the corrupt file
        fs.unlinkSync(filePath);
        console.log(`  🗑️  Deleted corrupt file`);
    }
});

console.log('\n' + '='.repeat(50));
console.log('Summary:');
console.log(`  Valid files: ${validCount}`);
console.log(`  Empty files: ${emptyCount} (deleted)`);
console.log(`  Corrupt files: ${corruptCount} (deleted)`);
console.log(`  Total processed: ${jsonFiles.length}`);
console.log('='.repeat(50));

if (corruptCount > 0 || emptyCount > 0) {
    console.log('\n⚠️  Backup files have been created before deletion');
    console.log('   Check the rooms directory for .backup files');
}
