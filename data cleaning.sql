-- Cleaning Data in SQL Queries

select*
from nashvillehousing;

--------------------------------------------------------------------------------------------------------------------------

 
-- Standardize Date Format 
-- current format  ' April 9, 2013 desired ' 04-09-2013'

select SaleDate =STR_TO_DATE(SaleDate, '%M %e, %Y')
from portfolioproject.nashvillehousing; 

UPDATE portfolioproject.nashvillehousing 
SET SaleDate =STR_TO_DATE(SaleDate, '%M %e, %Y');
--------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address data

-- some of the rows in the PropertyAddress are empty so we want to change it to nulls so we can handel it 
UPDATE nashvillehousing
SET PropertyAddress = NULL
WHERE PropertyAddress = ''; 
/*
we are joining two instances of the same table with different aliases, "a" and "b". The join is based on the ParcelID column, 
so only rows that have the same ParcelID value in both instances of the table will be joinede
The condition "a.UniqueID <> b.UniqueID" ensures that we don't join a row with itsel 
*/

select  a.UniqueID, a.ParcelID, a.PropertyAddress, b.UniqueID, b.PropertyAddress , b.ParcelID,
ifnull( a.PropertyAddress,b.PropertyAddress)
from portfolioproject.nashvillehousing a
join  portfolioproject.nashvillehousing b 
on a.ParcelID=b.ParcelID
and a.UniqueID <> b.UniqueID
where b.PropertyAddress is null;

-- a problem occured while updating the table: 'Error Code: 2013. Lost connection to MySQL server during query	30.094 sec'
-- solution : optimizing the query by indexing 
CREATE INDEX idx_ParcelID ON nashvillehousing (ParcelID(255));
-- here we Populate
update portfolioproject.nashvillehousing a
join portfolioproject.nashvillehousing b
 on a.UniqueID <> b.UniqueID
 and a.ParcelID=b.ParcelID
set b.PropertyAddress = ifnull(b.PropertyAddress,a.PropertyAddress) 
where b.PropertyAddress is null;
--------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

-- we have two ways of how we can Break values in a column 
-- 1
select substring(PropertyAddress,1,locate(',',PropertyAddress)-1) as adderss ,
substring(PropertyAddress,locate(',',PropertyAddress)+1,length(PropertyAddress)) as city
from nashvillehousing;
-- 2
select SUBSTRING_INDEX(OwnerAddress,",",1) as adderss ,
 SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1) as city ,
SUBSTRING_INDEX(OwnerAddress,",",-1) as state
from nashvillehousing;

alter table nashvillehousing
add column (
PropertySplitAddress  varchar(50) ,
 PropertySplitCity varchar(50));

update nashvillehousing
set
PropertySplitAddress =substring(PropertyAddress,1,locate(',',PropertyAddress)-1) ,
PropertySplitCity= substring(PropertyAddress,locate(',',PropertyAddress)+1,length(PropertyAddress));

alter table nashvillehousing
add column(
 OwnerSplitAddress varchar(50) ,
  OwnerSplitCity varchar(50) ,
  OwnerSpliState varchar(50));
  
update nashvillehousing
set 
OwnerSplitAddress= SUBSTRING_INDEX(OwnerAddress,",",1),
OwnerSplitCity =  SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1),
OwnerSpliState = SUBSTRING_INDEX(OwnerAddress,",",-1);

select PropertySplitAddress , PropertySplitCity , OwnerSplitAddress , OwnerSplitCity ,OwnerSpliState
from nashvillehousing ;

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant),count(SoldAsVacant)
from nashvillehousing 
group by SoldAsVacant  ;

select  
	case 
		when  SoldAsVacant ='n' then 'No'
		when SoldAsVacant ='y' then 'Yes' 
	end 
from nashvillehousing
where  SoldAsVacant ='y' or SoldAsVacant ='n' ;
 
UPDATE nashvillehousing
SET SoldAsVacant = (
    CASE 
        WHEN SoldAsVacant = 'n' THEN 'No'
        WHEN SoldAsVacant = 'y' THEN 'Yes'
    END
)
WHERE SoldAsVacant IN ('y', 'n');

--------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH row_num_cte AS (
  SELECT *,
    ROW_NUMBER() OVER(PARTITION BY 
      ParcelID,
      PropertyAddress,
      SalePrice,
      SaleDate,
      LegalReference
      ORDER BY UniqueID) AS row_num
  FROM nashvillehousing
)
DELETE FROM nashvillehousing 
WHERE UniqueID IN (
  SELECT UniqueID 
  FROM row_num_cte 
  WHERE row_num > 1
);
-- order by ParcelID



--------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns 
-- its not recommended to delete data 

alter table nashvillehousing
DROP COLUMN OwnerAddress, 
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress,
 DROP COLUMN SaleDate