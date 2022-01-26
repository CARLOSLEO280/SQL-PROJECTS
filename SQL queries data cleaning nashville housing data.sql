-- cleaning data in SQL Queries


Select * from PortfolioProject1..Nashvillehousing

-- change sale date parameters

Select SaleDateConverted, CONVERT(Date,SaleDate) from PortfolioProject1..Nashvillehousing

Update Nashvillehousing SET SaleDate = CONVERT(Date,SaleDate)

alter table Nashvillehousing
add SaleDateConverted Date;

Update Nashvillehousing SET SaleDateConverted = CONVERT(Date,SaleDate)

-- Populate Property Address Data

Select * from PortfolioProject1..Nashvillehousing 
--where PropertyAddress is null
order by ParcelID

--self Join to populate information where parcel id matches

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,
isnull(a.PropertyAddress, b.PropertyAddress) from PortfolioProject1..Nashvillehousing a
JOIN PortfolioProject1..Nashvillehousing b
on a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
SET PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject1..Nashvillehousing a
JOIN PortfolioProject1..Nashvillehousing b
on a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--breaking out address into individual columns(address,city,state)


Select * from PortfolioProject1..Nashvillehousing 


SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
from PortfolioProject1..Nashvillehousing 

alter table Nashvillehousing
add PropertySplitAddress Nvarchar(255);

Update Nashvillehousing SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table Nashvillehousing
add PropertySplitCity Nvarchar(255);

Update Nashvillehousing SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

Select OwnerAddress from PortfolioProject1..Nashvillehousing

Select PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2) 
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from PortfolioProject1..Nashvillehousing

alter table Nashvillehousing
add OwnerSplitAddress Nvarchar(255);

Update Nashvillehousing SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

alter table Nashvillehousing
add OwnerSplitCity Nvarchar(255);

Update Nashvillehousing SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2) 

alter table Nashvillehousing
add OwnerSplitState Nvarchar(255);

Update Nashvillehousing SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

--Change Y and N to Yes and No in "Sold as Vacant" field using case statement

Select Distinct(SoldAsVacant), Count(SoldAsVacant) from PortfolioProject1..Nashvillehousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
from PortfolioProject1..Nashvillehousing

UPDATE Nashvillehousing
Set SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


--Remove Duplicates

--using CTE
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference
	ORDER BY UniqueID) row_num
from PortfolioProject1..Nashvillehousing
--order by ParcelID
)
DELETE from RowNumCTE where row_num > 1 order by PropertyAddress

--Delete Unused Columns

ALTER TABLE PortfolioProject1..Nashvillehousing
DROP Column OwnerAddress,TaxDistrict,PropertyAddress

ALTER TABLE PortfolioProject1..Nashvillehousing
DROP Column SaleDate

Select * from PortfolioProject1..Nashvillehousing
