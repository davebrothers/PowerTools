#r "packages\WindowsAzure.Storage.8.1.4\lib\net45\Microsoft.WindowsAzure.Storage.dll"
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;

/*
    run me from PowerShell:
    > csi .\UpdateMimeTypes.csx {connectionString} {containerName}
 */

var args = Environment.GetCommandLineArgs();
var connectionString = args[2];
var containerName = args[3];

CloudBlobClient blobClient = CloudStorageAccount
    .Parse(connectionString)
    .CreateCloudBlobClient();

var blobs = blobClient
    .GetContainerReference(containerName)
    .ListBlobs(useFlatBlobListing: true)
    .OfType<CloudBlockBlob>();

var count = 0;

foreach (var blob in blobs)
{
    try
    {
        blob.DeleteIfExists();
        count++;
    }
    catch (System.Exception e)
    {
        System.Console.WriteLine(e.ToString());
        return;
    }
}

System.Console.WriteLine($"Deleted {count} blobs from {containerName} container.");
return;